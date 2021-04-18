attach 'wdi.sqlite3' as wdi;

create table names (id integer primary key, name text not null);
create table pagetypes (id integer primary key, name text not null);

insert into names (name) select distinct name from dbstat('wdi');
insert into pagetypes (name) select distinct pagetype from dbstat('wdi');

create table stat (
    pageno integer primary key,
    name references names (id) not null,
    pagetype references pagetypes (id) not null,
    number_of_cells integer not null,
    payload_bytes integer not null,
    unused_bytes integer not null
);

insert into stat select
    pageno,
    (select id from names where names.name = s.name),
    (select id from pagetypes where pagetypes.name = s.pagetype),
    ncell,
    payload,
    unused
    from dbstat('wdi') s;

vacuum;