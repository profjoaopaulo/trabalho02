package com.example;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class PedidoApp {

    // Configurações do banco de dados
    private static final String DB_URL = "jdbc:postgresql://localhost:5432/<NOME_BD>";
    private static final String USER = "<USER>"; // Usuário do PostgreSQL
    private static final String PASS = "<PASSWORD>"; // Senha do PostgreSQL

    private final Connection connection;

    /**
     * Construtor que estabelece a conexão com o banco de dados.
     * 
     * @throws SQLException Se ocorrer um erro ao conectar.
     */
    public PedidoApp() throws SQLException {
        this.connection = DriverManager.getConnection(DB_URL, USER, PASS);
        System.out.println("Conexão com o banco de dados estabelecida com sucesso!");
    }

    /**
     * Fecha a conexão com o banco de dados.
     */
    public void closeConnection() {
        if (connection != null) {
            try {
                connection.close();
                System.out.println("Conexão com o banco de dados fechada.");
            } catch (SQLException e) {
                System.err.println("Erro ao fechar a conexão com o banco de dados: " + e.getMessage());
            }
        }
    }

    /**
     * Chama a FUNCTION ObterPrecoProduto usando SELECT para obter o preço de um produto.
     * @param produtoId ID do produto.
     * @return O preço do produto ou -1 se ocorrer um erro.
     */
    public double getProdutoPrice(int produtoId) {
        // Usamos SELECT para chamar a função e um PreparedStatement para executar a consulta.
        String sql = "SELECT ObterPrecoProduto(?)";
        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            // Define o parâmetro de entrada para a função (o ID do produto)
            pstmt.setInt(1, produtoId);

            // Executa a consulta e obtém o ResultSet
            ResultSet rs = pstmt.executeQuery();

            // Verifica se há um resultado e retorna o preço
            if (rs.next()) {
                return rs.getDouble(1); // Obtém o valor da primeira coluna do resultado
            } else {
                System.err.println("Nenhum preço encontrado para o produto ID: " + produtoId);
                return -1; // Ou lançar uma exceção, dependendo da sua lógica de negócio
            }
        } catch (SQLException e) {
            System.err.println("Erro ao obter preço do produto: " + e.getMessage());
            return -1;
        }
    }

    /**
     * Chama a PROCEDURE RealizarPedido para criar um novo pedido e atualizar o
     * estoque.
     * 
     * @param produtoId  ID do produto.
     * @param quantidade Quantidade do pedido.
     */
    public void makeOrder(int produtoId, int quantidade) {
        String sql = "CALL RealizarPedido(?, ?)"; // Sintaxe para chamar procedure
        try (CallableStatement cstmt = connection.prepareCall(sql)) {
            cstmt.setInt(1, produtoId);
            cstmt.setInt(2, quantidade);
            cstmt.execute();
            System.out.println("Chamada da procedure RealizarPedido executada com sucesso para produto ID " + produtoId
                    + " e quantidade " + quantidade);
        } catch (SQLException e) {
            System.err.println("Erro ao realizar pedido: " + e.getMessage());
            // Aqui você pode tratar exceções específicas de acordo com a mensagem de erro
            // do banco
        }
    }

    /**
     * Verifica o estoque atual de um produto.
     * 
     * @param produtoId ID do produto.
     */
    public void checkProductStock(int produtoId) {
        String sql = "SELECT nome, estoque FROM produtos WHERE id = ?";
        try (PreparedStatement pstmt = connection.prepareStatement(sql)) {
            pstmt.setInt(1, produtoId);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                System.out.println("Produto: " + rs.getString("nome") + ", Estoque Atual: " + rs.getInt("estoque"));
            } else {
                System.out.println("Produto com ID " + produtoId + " não encontrado.");
            }
        } catch (SQLException e) {
            System.err.println("Erro ao verificar estoque: " + e.getMessage());
        }
    }
}
