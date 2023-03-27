module SpreeCmCommissioner
  class InvoiceCreator < BaseInteractor
    delegate :order, to: :context

    def call
      load_invoice_number
      create_invoice
    end

    # 0412 + 000001
    def load_invoice_number
      load_prefix
      load_invoices_count

      context.invoice_number = context.prefix + rjust_number(context.invoices_count)
    end

    # 04-12-2023 -> 0412
    def load_prefix
      context.prefix = order.line_items.first.from_date.strftime('%m%y')
    end

    def load_invoices_count
      from = order.line_items.first.from_date.beginning_of_month
      to = order.line_items.first.from_date.end_of_month

      context.invoices_count = SpreeCmCommissioner::Invoice.where(
        vendor: order.line_items.first.vendor,
        date: from..to
      ).size
    end

    def create_invoice
      context.invoice = SpreeCmCommissioner::Invoice.where(
        vendor: order.line_items.first.vendor,
        order: order,
        date: order.line_items.first.from_date
      ).first_or_create do |invoice|
        invoice.invoice_number = context.invoice_number
      end
    end

    # 1 -> 000001
    def rjust_number(invoices_count)
      (invoices_count + 1).to_s.rjust(6, '0')
    end
  end
end
