class CreatePedidos < ActiveRecord::Migration[8.1]
  def change
    create_table :pedidos do |t|
      # references cria a coluna cliente_id, o indice e a chave estrangeira.
      # foreign_key: true faz o banco recusar um pedido apontando para cliente inexistente.
      t.references :cliente, null: false, foreign_key: true
      t.string :status, null: false, default: "pendente"
      t.decimal :total, precision: 10, scale: 2, null: false, default: 0

      t.timestamps
    end
  end
end
