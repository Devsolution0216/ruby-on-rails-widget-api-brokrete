module Types
  class MutationType < Types::BaseObject
    field :contractor_sign_in,                mutation: Mutations::Contractor::SignIn
    field :contractor_sign_up,                mutation: Mutations::Contractor::SignUp

    field :contractor_update,                 mutation: Mutations::Contractor::Update

    field :contractor_confirm_identity,       mutation: Mutations::Contractor::ConfirmIdentity

    field :contractor_forgot_password,        mutation: Mutations::Contractor::ForgotPassword
    field :contractor_reset_password,         mutation: Mutations::Contractor::ResetPassword
    field :contractor_validate_reset_token,   mutation: Mutations::Contractor::ValidateResetToken

    field :payment_create,                    mutation: Mutations::Payment::Create

    field :config,                            mutation: Mutations::Config

    field :order_create,                      mutation: Mutations::Order::Create
    field :order_validate,                    mutation: Mutations::Order::Validate
    field :order_hold,                        mutation: Mutations::Order::Hold
    field :order_release,                     mutation: Mutations::Order::Release
  end
end
