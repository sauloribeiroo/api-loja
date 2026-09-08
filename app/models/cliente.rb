class Cliente < ApplicationRecord
  # normalizes roda ANTES das validacoes, diferente de before_save.
  # Assim "  ANA@X.COM " vira "ana@x.com" e so depois e validado e comparado
  # com o indice unico do banco.
  normalizes :email, with: ->(email) { email.to_s.strip.downcase }
  normalizes :nome, with: ->(nome) { nome.to_s.strip }

  validates :nome, presence: true, length: { minimum: 3, maximum: 100 }

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "nao e um email valido" }

  validates :telefone, length: { maximum: 20 }, allow_blank: true
end
