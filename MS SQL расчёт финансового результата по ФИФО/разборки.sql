--по сайту https://tsql-tasks.blogspot.com/2014/09/fifo.html

if object_id ( 'tempdb..#Orders', 'U' ) is not null
    drop table #Orders
create table #Orders
(OrdNum int   not null, OrdSum float not null,primary key clustered ( OrdNum asc) on [PRIMARY]) on [PRIMARY]

insert into #Orders ( OrdNum, OrdSum )
    values( 1, 100 ),( 2, 200 ),( 3, 500 ),( 4, 90 )

if object_id ( 'tempdb..#Repayments', 'U' ) is not null
       drop table #Repayments
create table #Repayments
(RepayDate    date   not null,RepaySum     float  not null,primary key clustered ( RepayDate asc ) on [PRIMARY]) on [PRIMARY]

insert into #Repayments ( RepayDate, RepaySum )
    values( '2014-01-01', 90 ),( '2014-01-02', 20 ),( '2014-01-03', 90 ),( '2014-01-04', 150 ),( '2014-01-05', 20 ),( '2014-01-06', 10 ),( '2014-01-07', 34 ),( '2014-01-08', 123),( '2014-01-09', 400 ),
        ( '2014-01-10', 40 )

/*
select RepayDate, sum ( RepaySum ) over ( order by RepayDate
    rows between unbounded preceding and current row ) RepaySum
from #Repayments
*/
declare @minOrdNum int = ( select min ( OrdNum ) from #Orders );
with Repayments
as(select RepayDate, RepaySum, row_number () over ( order by RepayDate ) RowId
    from #Repayments)

select *
from 
(
    select data.*, row_number () over ( partition by num order by num ) as newnum
    from
    (
        select repays.RowId, ord.OrdNum, ord.OrdSum, repays.RepayDate, repays.RepaySum,
            dense_rank () over ( order by -sign ( case when ord.OrdSum - repays.RepaySum = 0 then -1
                else ord.OrdSum - repays.RepaySum end ) ) num,
            ord.OrdSum - repays.RepaySum diff,
            -sign ( case when ord.OrdSum - repays.RepaySum = 0 then -1 else ord.OrdSum - repays.RepaySum end ) signum
        from #Orders ord
            cross join
            (
                select RowId, RepayDate,
                    sum ( RepaySum ) over
                    ( order by RepayDate rows between unbounded preceding and current row ) RepaySum
                from Repayments
            ) repays
        where ord.OrdNum = @minOrdNum

    ) data
) data
where
    case when data.signum = 1 then 0 else data.num end = 1 or
    data.newnum = 1



drop table #Orders
drop table #Repayments

