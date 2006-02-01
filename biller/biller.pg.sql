CREATE TABLE clients (
    id serial NOT NULL,
    code character varying(5),
    name character varying(255),
    towho character varying(255)
);

CREATE TABLE invoices (
    id serial NOT NULL,
    client_id integer,
    sent_date timestamp not null default 'now'
);

CREATE TABLE items (
    id serial NOT NULL,
    client_id integer,
    item_date timestamp not null default 'now',
    description character varying(255),
    hours double precision,
    billed boolean not null default 'false',
    invoice_id integer
);
