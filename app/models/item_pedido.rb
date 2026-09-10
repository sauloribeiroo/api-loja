class ItemPedido < ApplicationRecord
  belongs_to :pedido, inverse_of: :itens
  belongs_to :produto

  validates :quantidade,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 }
  validates :preco_unitario,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }
  validates :produto_id, uniqueness: { scope: :pedido_id, message: "ja esta neste pedido" }

  # Copia o preco atual do produto ANTES de validar. E por isso que a API nunca
  # recebe preco do cliente: quem manda e o que esta gravado no banco.
  before_validation :copiar_preco_do_produto, on: :create

  validate :produto_tem_estoque, on: :create

  def subtotal
    return 0 if preco_unitario.blank? || quantidade.blank?
    preco_unitario * quantidade
  end

  private

  def copiar_preco_do_produto
    self.preco_unitario = produto.preco if produto.present? && preco_unitario.blank?
  end

  def produto_tem_estoque
    return if produto.blank? || quantidade.blank?

    unless produto.disponivel?(quantidade)
      errors.add(:quantidade,
                 "indisponivel: o produto '#{produto.nome}' tem apenas #{produto.estoque} em estoque")
    end
  end
end
