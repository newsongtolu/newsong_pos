class OrderMailer < ApplicationMailer
  default from: "no-reply@newsongpos.com"

  def updated_receipt(order)
    @order = order
    mail(
      to: @order.email,
      subject: "Your Updated E-Receipt for Order ##{@order.id} - NewsongPos"
    )
  end
end