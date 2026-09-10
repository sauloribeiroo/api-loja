class Produto < ApplicationRecord
  has_many :itens_pedido, class_name: "ItemPedido", dependent: :restrict_with_error
  has_many :pedidos, through: :itens_pedido

  normalizes :nome, with: ->(nome) { nome.to_s.strip }

  validates :nome, presence: true, length: { minimum: 2, maximum: 120 }
  validates :descricao, length: { maximum: 1000 }, allow_blank: true
  validates :preco, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :estoque,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Verifica se ha estoque para atender a quantidade pedida.
  def disponivel?(quantidade)
    estoque >= quantidade.to_i
  end

  # Usado quando um pedido e criado. O update_column pula validacoes e
  # callbacks de proposito: a checagem de estoque ja foi feita antes,
  # e aqui so queremos gravar o novo saldo.
  def baixar_estoque!(quantidade)
    update_column(:estoque, estoque - quantidade.to_i)
  end

  def devolver_estoque!(quantidade)
    update_column(:estoque, estoque + quantidade.to_i)
  end
end
