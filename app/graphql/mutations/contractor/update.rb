module Mutations
  class Contractor::Update < ContractorBase

    argument :identity, Types::Identity::UpdateInputType, required: false
    argument :info, Types::Contractor::UpdateInfoInputType, required: false
    argument :payments_info, Types::Contractor::UpdatePaymentsInfoInputType, required: false

    def resolve(identity: nil, info: nil, payments_info: nil)
      resolve_identity **identity if identity.present?
      resolve_info **info if info.present?
      resolve_payments_info **payments_info if payments_info.present?

      success
    rescue Error => e
      error! e
    end

    private

    def resolve_identity(change: nil, add: nil, remove: nil)
      change.each { |item| resolve_change_identity(**item) } if change.present?
      add.   each { |item| resolve_add_identity(   **item) } if add.present?
      remove.each { |item| resolve_remove_identity(**item) } if remove.present?
    end

    def resolve_change_identity(email: nil, phone: nil, password: nil)
      if email.present?
        result = Operations::Contractor::Identity::Update.(
          contractor: contractor, provider: :email, uid: email[:from], new_uid: email[:to])

        raise result if result.error?
      end

      if phone.present?
        result = Operations::Contractor::Identity::Update.(
          contractor: contractor, provider: :phone, uid: phone[:from], new_uid: phone[:to])

        raise result if result.error?
      end

      if password.present?
        result = Operations::Contractor::ChangePassword.(
          contractor: contractor, current_token: password[:from], token: password[:to]
        )

        raise result if result.error?
      end
    end

    def resolve_add_identity(email: nil, phone: nil)
      if email.present?
        result = Operations::Contractor::Identity::Create.(
          contractor: contractor, provider: :email, uid: email)

        raise result if result.error?
      end

      if phone.present?
        result = Operations::Contractor::Identity::Create.(
          contractor: contractor, provider: :phone, uid: phone)

        raise result if result.error?
      end
    end

    def resolve_remove_identity(email: nil, phone: nil)
      if email.present?
        result = Operations::Contractor::Identity::Remove.(
          contractor: contractor, provider: :email, uid: email)

        raise result if result.error?
      end

      if phone.present?
        result = Operations::Contractor::Identity::Remove.(
          contractor: contractor, provider: :phone, uid: phone)

        raise result if result.error?
      end
    end

    def resolve_info(**params)
      result = Operations::Contractor::Update.(
        contractor: contractor,
        **params
      )

      raise result if result.error?
    end

    def resolve_payments_info(add_payment_card: nil, remove_payment_card: nil, default_payment_method: nil)
      add_payment_card.each { |item| resolve_add_payment_card(**item) } if add_payment_card.present?
      remove_payment_card.each { |item| resolve_remove_payment_card(item) } if remove_payment_card.present?
      resolve_default_payment_method(default_payment_method) if default_payment_method.present?
    end

    def resolve_add_payment_card(card:)
      result = Operations::Contractor::PaymentCard::Add.(
        contractor: contractor,
        card: card
      )

      raise result if result.error?
    end

    def resolve_remove_payment_card(id)
      result = Operations::Contractor::PaymentCard::Remove.(
        contractor: contractor,
        id: id
      )

      raise result if result.error?
    end

    def resolve_default_payment_method(provider:, card_id: nil)
      result = Operations::Contractor::Payment::SetDefaultPaymentMethod.(
        contractor: contractor,
        provider: provider.to_sym,
        card_id: card_id
      )

      raise result if result.error?
    end
  end
end
