/*
написать расчёт финансового результата(дохода/убытка) по методу ФИФО после каждой сделки.
Финансовый результат возникает в момент совершения сделки, обратной текущей накопленной позиции, например клиент совершил 3 покупки на 300 бумаг, 
потом 1 продажу на 100 бумаг, потом опять покупку на 100 бумаг, потом ещё продажу на 200 бумаг.
В данном случае финансовый результат будет возникать при каждой продаже - прибыль или убыток. При покупках финансового результата нет.

Попытаться решить задачу без циклов и курсоров
*/

IF OBJECT_ID('tempdb..#deal') IS NOT NULL DROP TABLE #deal
CREATE TABLE #deal ( [date_oper] datetime, [client] varchar(64), [share] VARCHAR(20), [quantity] decimal(19,7), price decimal(19,7))
INSERT INTO #deal
VALUES
( '2022-01-13T17:36:32', '016084', 'VTBR', 15000000, 0.006013),
( '2022-01-13T17:36:37', '016084', 'VTBR', 10000000, 0.006014),
( '2022-01-13T17:36:39', '016084', 'VTBR', 10000000, 0.006015), 
( '2022-01-13T17:36:40', '016084', 'VTBR', 7000000, 0.006012), 
( '2022-01-13T21:23:07', '016084', 'VTBR', -40000000, 0.006020), 
( '2022-01-13T21:23:10', '016084', 'VTBR', 1000000, 0.006016),
( '2022-01-13T21:23:12', '016084', 'VTBR', 10000000, 0.006018), 
( '2022-01-13T21:23:18', '016084', 'VTBR', -1500000, 0.006012), 
( '2022-01-13T21:23:19', '016084', 'VTBR', -1000000, 0.006013), 
( '2022-01-13T21:23:26', '016084', 'VTBR', -500000, 0.006010),
( '2022-01-13T21:23:28', '016084', 'VTBR', -2000000, 0.006025), 
( '2022-01-13T21:23:33', '016084', 'VTBR', -2000000, 0.006030),
( '2022-01-13T21:23:34', '016084', 'VTBR', -6000000, 0.006030),
('2022-01-14T10:10:34', '016085', 'ADT', 0.5367, 80.15),
('2022-01-14T11:15:18', '016085', 'ADT', 0.483, 81.15),
('2022-01-14T11:15:19', '016085', 'ADT', 0.283, 81.15),
('2022-01-14T12:15:20', '016085', 'ADT', -1.0889, 82.25),
('2022-01-14T12:15:21', '016085', 'ADT', -0.2138, 82.28);
--select * from #deal; return;
--declare @client varchar(64) = '016084', @share VARCHAR(20) = 'VTBR';

--покупки и продажи распедаливаем по разным таблицам
--покупки
IF OBJECT_ID('tempdb..#buy') IS NOT NULL DROP TABLE #buy
CREATE TABLE #buy (buy_id integer IDENTITY(1,1) PRIMARY KEY NOT NULL, 
date_oper datetime, client varchar(64), share VARCHAR(20), quantity_buy decimal(19,7), price_buy decimal(19,7))

INSERT INTO #buy 
select *  from #deal 
where quantity > 0-- and client = @client and share = @share
order by client, share, date_oper
--select * from #buy

--продажи
IF OBJECT_ID('tempdb..#sale') IS NOT NULL DROP TABLE #sale 
CREATE TABLE #sale (sale_id integer IDENTITY(1,1) PRIMARY KEY NOT NULL, 
date_oper datetime, client varchar(64), share VARCHAR(20), quantity_sale decimal(19,7), price_sale decimal(19,7))

INSERT INTO #sale
select *  from #deal where quantity < 0--and client = @client and share = @share
order by client, share, date_oper
--select * from #sale
--return

--покупки закрываемые продажей
IF OBJECT_ID('tempdb..#buy_close') IS NOT NULL DROP TABLE #buy_close
CREATE TABLE #buy_close (buy_close_id integer IDENTITY(1,1) PRIMARY KEY NOT NULL, 
buy_id integer, sale_id integer, quantity_close decimal(19,7))

ALTER TABLE #buy_close ADD CONSTRAINT FK_buy_close_buy FOREIGN KEY (buy_id) REFERENCES #buy (buy_id);
ALTER TABLE #buy_close ADD CONSTRAINT FK_buy_close_sale FOREIGN KEY (buy_id) REFERENCES #sale (sale_id);


/*select top(1) s.sale_id, s.quantity_sale, s.price_sale, (select SUM(bc.quantity_close) quantity_close  from #buy_close bc where bc.sale_id = s.sale_id) quantity_close
from #sale s
*/

declare @sale_id int = -1;
--старт
while @sale_id is not null begin
  set @sale_id = null;
  
  --берём первую продажу без привязанных покупок
  select top(1) @sale_id = sale_id  
  from(select s.sale_id, s.date_oper, s.quantity_sale, 
	          (select isnull(SUM(bc.quantity_close), 0)   from #buy_close bc where bc.sale_id = s.sale_id) quantity_close
       from #sale s) t
  where t.quantity_sale+t.quantity_close <> 0

  --больше нет продаж без привязанных покупок
  if @sale_id is null 
    BREAK;

  /*select top(1) *   from( 
                select s.sale_id, s.date_oper, s.quantity_sale, (select isnull(SUM(bc.quantity_close), 0)   from #buy_close bc where bc.sale_id = s.sale_id) quantity_close
                from #sale s) t
                where t.quantity_sale+t.quantity_close <> 0*/

  --записываем закрывающие продажу покупки и формируем связи к #sale и #buy
  INSERT INTO #buy_close(buy_id, sale_id, quantity_close) 
  select buy_id, sale_id, quantity_4_close
  from(
    select buy_id, sale_id, 
           (case when quantity_buy_cum <= quantity_sale then quantity_buy-quantity_close else (quantity_buy-quantity_close)-(quantity_buy_cum-quantity_sale) end) quantity_4_close
    from(
	  --перемножаем свободную продажу с покупками перед ней
      select t.buy_id, t.date_oper, t.quantity_buy, t.price_buy, t.sale_id, t.quantity_sale, 
             t.quantity_close, 
             SUM(t.quantity_buy-t.quantity_close) over(order by t.date_oper rows between unbounded preceding and current row) quantity_buy_cum
      from (
        select b.buy_id, b.date_oper, b.quantity_buy, b.price_buy, s.sale_id, (-1*s.quantity_sale) quantity_sale, 
               isnull((select SUM(bc.quantity_close) from #buy_close bc where bc.buy_id = b.buy_id), 0) quantity_close
        from #buy b
        cross join (
          select top(1) * from( 
                  select s.sale_id, s.date_oper, s.quantity_sale, (select isnull(SUM(bc.quantity_close), 0)   from #buy_close bc where bc.sale_id = s.sale_id) quantity_close
                  from #sale s) t
                  where t.quantity_sale+t.quantity_close <> 0
    	) s
        where b.date_oper <= s.date_oper 
      ) t where t.quantity_buy-t.quantity_close > 0.01

    )tt
  )ttt where ttt.quantity_4_close > 0

end;

---контроль
--select * from #buy_close

select 'финансовый результат "sum_income"'
select sale_id, date_oper, client, share, quantity_sale, price_sale, sum_sale, sum_buy_4_sale, (sum_sale-sum_buy_4_sale) sum_income
from (
  select s.sale_id, s.date_oper, s.client, s.share, s.quantity_sale, s.price_sale, (-1*s.quantity_sale*s.price_sale) sum_sale,
         (Select SUM(bc.quantity_close*b.price_buy) from  #buy_close bc 
          join #buy b on (b.buy_id = bc.buy_id) 
          where bc.sale_id = s.sale_id) sum_buy_4_sale
  from #sale s
) t


select 'суммарный доход "cumulative_total"'
select client, share, date_oper,  quantity, price, SUM(quantity*price) sum_oper, SUM(quantity*price) over (PARTITION BY client, share order by client, share
    rows between unbounded preceding and current row ) cumulative_total
from #deal
group by client, share, date_oper, quantity, price


drop TABLE #deal
drop TABLE #buy
drop TABLE #buy_close
drop TABLE #sale
--суммарный доход по VTBR = -361
--по ADT = -1.66