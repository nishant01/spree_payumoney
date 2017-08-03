module Spree
  class PayumoneyController < StoreController
    protect_from_forgery only: :index


    def index
      @surl = payumoney_confirm_url
      @furl = payumoney_cancel_url
      @productinfo = 'apparel'
      payment_method = Spree::PaymentMethod.find(params[:payment_method_id])
      order = Spree::Order.find_by_number!(params[:order])
      @service_url = payment_method.provider.service_url
      @merchant_key = payment_method.preferred_merchant_id

      @txnid = payment_method.txnid(order)
      @amount = order.total.to_s
      @email = order.email

      if(address = order.bill_address || order.ship_address)
        @phone = address.phone #udf2
        @firstname = address.firstname
        @lastname = address.lastname #udf1
        @city = address.city #udf3
      end
      #filling up all udfs
      #not sure if necessary by offsite payments
      @payment_method_id = payment_method.id #udf4

      @checksum = payment_method.checksum([@txnid, @amount, @productinfo, @firstname, @email, @lastname, @phone, @city, @payment_method_id, '', '', '', '', '', '']);
      @service_provider = payment_method.service_provider
    end

    def confirm
      payment_method = Spree::PaymentMethod.find(payment_method_id)

      Spree::LogEntry.create({
                                 source: payment_method,
                                 details: params.to_yaml
                             })

      order = current_order || raise(ActiveRecord::RecordNotFound)

      if(address = order.bill_address || order.ship_address)
        firstname = address.firstname
      end

      #confirm for correct hash and order amount requested before marking an payment as 'complete'
      checksum_matched = payment_method.checksum_ok?([params[:status], '', '', '', '', '', '', params[:udf4], params[:udf3], params[:udf2], params[:udf1], order.email, firstname, @productinfo, params[:amount], params[:txnid]], params[:hash])
      if !checksum_matched
        flash.alert = 'Malicious transaction detected.'
        redirect_to checkout_state_path(order.state)
        return
      end
      #check for order amount
      if !payment_method.amount_ok?(order.total, params[:amount])
        flash.alert = 'Malicious transaction detected. Order amount not matched.'
        redirect_to checkout_state_path(order.state)
        return
      end

      payment = order.payments.create!({
                                           source_type: 'Spree::Gateway::Payumoney',#could be something generated by system
                                           amount: order.total,
                                           payment_method: payment_method
                                       })

      #mark payment as paid/complete
      payment.complete

      order.next
      order.update_attributes({:state => "complete", :completed_at => Time.now})

      if order.complete?
        order.update!
        flash.notice = Spree.t(:order_processed_successfully)

        redirect_to order_path(order)
        return
      else
        redirect_to checkout_state_path(order.state)
        return
      end
    end

    def cancel
      #log some entry into table
      Spree::LogEntry.create({
                                 source: 'Spree::Gateway::Payumoney',
                                 details: params.to_yaml
                             })

      flash[:notice] = "Don't want to use Payumoney? No problems."
      #redirect to payment path and ask user to complete checkout
      #with different payment method
      redirect_to checkout_state_path(current_order.state)
    end

    private
    def payment_method_id
      params[:udf4]
    end
  end
end
