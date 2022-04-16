# Qirby Optimisation

## Query 1 - Select and Join
Show the codigo, designacao, ano_letivo, inscritos, tipo, and turnos for the course 'Bases de Dados' of the program 275.

**SQL Query**
```sql
SELECT CODIGO, DESIGNACAO, ANO_LETIVO, INSCRITOS, TIPO, TURNOS
    FROM XUCS
        INNER JOIN XOCORRENCIAS USING(CODIGO)
        INNER JOIN XTIPOSAULA USING (ANO_LETIVO, PERIODO, CODIGO)
    WHERE DESIGNACAO = 'Bases de Dados' AND CURSO = 275;
```

**Result**

![Query 1 results](images/query1_result.png)

**Execution Plan**

*X-Environment*
![Query 1 execution plan in X environment](images/query1_plan_x.png)

*Y-Environment*
![Query 1 execution plan in Y environment](images/query1_plan_y.png)

**Execution Time**

- *X-Environment* - `0.059s`
- *Y-Environment* - `0.030s`