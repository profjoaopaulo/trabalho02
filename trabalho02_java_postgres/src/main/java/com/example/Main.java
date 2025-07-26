package com.example;

import java.sql.SQLException;

public class Main {

    public static void main(String[] args) {

        PedidoApp app = null; // Inicializa como null para garantir que o finally funcione
        try {
            app = new PedidoApp();

            // Chamada de uma FUNCTION: ObterPrecoProduto
            System.out.println("\n--- Chamando FUNCTION: ObterPrecoProduto ---");
            int produtoId = 1; // ID do Smartphone
            double precoProduto = app.getProdutoPrice(produtoId);
            if (precoProduto != -1) {
                System.out.println("Preço do produto (ID: " + produtoId + "): R$" + precoProduto);
            }

            // Chamada de uma PROCEDURE: RealizarPedido
            System.out.println("\n--- Chamando PROCEDURE: RealizarPedido ---");
            int produtoIdPedido = 1; // ID do Smartphone
            int quantidadePedido = 2; // Pedindo duas unidades
            app.makeOrder(produtoIdPedido, quantidadePedido);

            // Tentar um pedido que deve acionar o TRIGGER de estoque insuficiente
            System.out.println("\n--- Tentando pedido com estoque insuficiente ---");
            app.makeOrder(2, 60); // Notebook tem 50 de estoque

            // Tentar um pedido com quantidade zero, para acionar o TRIGGER
            // ValidarQuantidadePedido
            System.out.println("\n--- Tentando pedido com quantidade zero ---");
            app.makeOrder(3, 0);

            // Verificar o estoque após os pedidos (para ver o efeito da PROCEDURE e
            // TRIGGER)
            System.out.println("\n--- Verificando estoque do produto ID 1 ---");
            app.checkProductStock(1);
            System.out.println("\n--- Verificando estoque do produto ID 2 ---");
            app.checkProductStock(2);
            System.out.println("\n--- Verificando estoque do produto ID 3 ---");
            app.checkProductStock(3);

        } catch (SQLException e) {
            System.err.println("Erro fatal na aplicação: " + e.getMessage());
        } finally {
            // Garante que a conexão seja fechada, mesmo se ocorrerem erros
            if (app != null) {
                app.closeConnection();
            }
        }
    }
}
