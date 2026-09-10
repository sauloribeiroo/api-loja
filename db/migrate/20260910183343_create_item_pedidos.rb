class CreateItemPedidos < ActiveRecord::Migration[8.1]
  def change
    create_table :item_pedidos do |t|
      t.references :pedido, null: false, foreign_key: true
      t.references :produto, null: false, foreign_key: true
      t.integer :quantidade, null: false
      # Congela o preco do produto no momento da venda. Se o produto for
      # reajustado depois, o pedido antigo mantem o valor da epoca.
      t.decimal :preco_unitario, precision: 10, scale: 2, null: false

      t.timestamps
    end

    # O mesmo produto nao pode aparecer duas vezes no mesmo pedido:
    # se o cliente quer 2 unidades, isso e quantidade, nao duas linhas.
    add_index :item_pedidos, [ :pedido_id, :produto_id ], unique: true
    add_check_constraint :item_pedidos, "quantidade > 0", name: "quantidade_positiva"
  end
end
