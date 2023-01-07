/*
�������� ������ ����������� ����������(������/������) �� ������ ���� ����� ������ ������.
���������� ��������� ��������� � ������ ���������� ������, �������� ������� ����������� �������, �������� ������ �������� 3 ������� �� 300 �����, 
����� 1 ������� �� 100 �����, ����� ����� ������� �� 100 �����, ����� ��� ������� �� 200 �����.
� ������ ������ ���������� ��������� ����� ��������� ��� ������ ������� - ������� ��� ������. ��� �������� ����������� ���������� ���.

���������� ������ ������ ��� ������ � ��������
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

--https://www.kodyaz.com/t-sql/fifo-example-query-in-sql-server.aspx
--https://tsql-tasks.blogspot.com/2014/09/fifo.html
--https://thisisdata.ru/blog/uchimsya-primenyat-okonnyye-funktsii/

declare @client varchar(64) = '016084', @share VARCHAR(20) = 'VTBR';

select b.date_oper, b.client, b.share, b.quantity, b.price,
(case when b.quantity < 0 then (select SUM(s.quantity) from #deal s where s.quantity > 0 and s.date_oper <= b.date_oper and s.client = b.client and s.share = b.share) else null end)
from #deal b
where b.date_oper <= '2022-01-13 21:23:07.000'  and b.client = @client and b.share = @share
order by b.date_oper

select date_oper, quantity, price, SUM(quantity*price) sum_oper, SUM(quantity*price) over ( order by date_oper
    rows between unbounded preceding and current row ) cumulative_total
from #deal
where client = @client and share = @share and  date_oper <= '2022-01-13 21:23:07.000'
group by date_oper, quantity, price
order by date_oper;


with oper
as (
select date_oper, sum(pay) pay, sum(bay) bay 
from (
select date_oper, (quantity) pay, cast(0 as decimal(19,7)) bay from #deal where quantity > 0 and client = @client and share = @share and  date_oper <= '2022-01-13 21:23:07.000'
union all
select date_oper, cast(0 as decimal(19,7)) pay, (quantity) bay  from #deal where quantity < 0 and client = @client and share = @share and  date_oper <= '2022-01-13 21:23:07.000'
) tt
group by date_oper
)

select date_oper, pay, bay, 
(case when bay < 0 then  1 else null end) tt
from oper

/*
with bay (date_oper, q)
as (
select date_oper, quantity
from #deal
where client = @client and share = @share and quantity < 0
),
pay (date_oper, q)
as (
select date_oper, (quantity) q
from #deal
where client = @client and share = @share and quantity > 0
)



select date_oper, quantity, price, SUM(quantity*price) sum_oper, SUM(quantity*price) over ( order by date_oper
    rows between unbounded preceding and current row ) cumulative_total
from #deal
where client = @client and share = @share and quantity > 0
group by date_oper, quantity, price
order by date_oper
*/
/*select RepayDate, sum ( RepaySum ) over ( order by RepayDate
    rows between unbounded preceding and current row ) RepaySum
from #Repayments
*/

drop TABLE #deal
--��������� ����� �� VTBR = -361
--�� ADT = -1.66