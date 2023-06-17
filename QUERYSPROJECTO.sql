USE RETROSARIA


--Crie as consultas à base de dados (comandos select) que permitam consultar:

--a. Todas as lojas da zona de Lisboa
SELECT * FROM LOJAS WHERE MORADA LIKE '%Lisboa%';

--b. Informação sobre os trabalhos não concluídos, por ordem crescente de data de início
SELECT * FROM PEDIDOS
WHERE CONCLUIDO = 0
ORDER BY DATA_INICIO ASC

--c. Os trabalhos urgentes aceites, solicitados pelo cliente
SELECT * FROM PEDIDOS 
wHERE URGENCIA = 1


--d. O arranjo mais caro
SELECT TOP 1 * FROM ARRANJOS ORDER BY CUSTO DESC;

--e. O custo do arranjo das peças, por tipo de arranjo
SELECT ARRANJOS.TIPO, SUM(ARRANJOS.CUSTO) AS CUSTO_TOTAL
FROM ARRANJOS
JOIN PEDIDOS_ARRANJOS ON ARRANJOS.ARRANJOID = PEDIDOS_ARRANJOS.ARRANJOID
GROUP BY ARRANJOS.TIPO;

--f. O tipo de arranjo que nunca foi pedido
SELECT TIPO FROM ARRANJOS WHERE ARRANJOID NOT IN (SELECT ARRANJOID FROM PEDIDOS_ARRANJOS);

--g. A loja que tem mais pedidos entregues
SELECT LOJAS.NOME, COUNT(PEDIDOS.PEDIDOID) AS TOTAL_PEDIDOS
FROM LOJAS
JOIN PEDIDOS ON LOJAS.LOJAID = PEDIDOS.LOJAID
WHERE PEDIDOS.CONCLUIDO = 1
GROUP BY LOJAS.NOME
ORDER BY TOTAL_PEDIDOS DESC 

--h. A quantidade de peças arranjadas da loja 1, dos últimos 7 dias
SELECT COUNT(*) AS Quantidade_Pecas_Arranjadas
FROM PEDIDOS
WHERE LOJAID = 1
  AND DATEDIFF(day, DATA_FIM, GETDATE()) <= 7;
 

--i. Os trabalhos que incluem arranjos de camisas e que ainda não foram levantados
SELECT P.PEDIDOID, L.NOME, P.CLIENTE, P.DATA_INICIO, P.DATA_FIM, P.CONCLUIDO
FROM PEDIDOS P
JOIN LOJAS L ON P.LOJAID = L.LOJAID
WHERE P.CONCLUIDO = 1;


--j. Os trabalhos que não foram pagos e foram devolvidos
SELECT * FROM PEDIDOS WHERE PAGO = 0 AND DEVOLVIDO = 1;

--k. Os pedidos urgentes que incluem peças com pelo menos 2 cores diferentes
SELECT *
FROM PEDIDOS P
JOIN PEDIDOS_PECAS PP ON P.PEDIDOID = PP.PEDIDOID
JOIN PECAS PE ON PP.PECAID = PE.PECAID
WHERE P.URGENCIA = 1


--l. Os trabalhos não devolvidos com a indicação nas observações de que são peças sensíveis
SELECT * FROM PEDIDOS WHERE DEVOLVIDO = 0 AND OBSERVACOES LIKE '%peças sensíveis%';

--m. Os trabalhos urgentes que foram mais caros do que todos os trabalhos não urgentes.
SELECT P.PEDIDOID, A.TIPO, A.CUSTO
FROM PEDIDOS_ARRANJOS PA
JOIN ARRANJOS A ON PA.ARRANJOID = A.ARRANJOID
JOIN PEDIDOS P ON PA.PEDIDOID = P.PEDIDOID
WHERE P.URGENCIA = 1
GROUP BY P.PEDIDOID, A.TIPO, A.CUSTO
HAVING A.CUSTO > ALL (
    SELECT A2.CUSTO
    FROM PEDIDOS_ARRANJOS PA2
    JOIN ARRANJOS A2 ON PA2.ARRANJOID = A2.ARRANJOID
    JOIN PEDIDOS P2 ON PA2.PEDIDOID = P2.PEDIDOID
    WHERE P2.URGENCIA = 0
);

--n. A loja que teve menos valor faturado no último mês
SELECT LOJAS.NOME, SUM(RECIBOS.VALOR) AS VALOR_FATURADO
FROM LOJAS
JOIN PEDIDOS ON LOJAS.LOJAID = PEDIDOS.LOJAID
JOIN RECIBOS ON PEDIDOS.PEDIDOID = RECIBOS.PEDIDOID
WHERE PEDIDOS.DATA_FIM >= DATEADD(month, -1, GETDATE())
GROUP BY LOJAS.NOME
ORDER BY VALOR_FATURADO ASC
