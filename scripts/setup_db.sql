create database quickvpn;

CREATE TABLE "host" (
  "id" serial NOT NULL,
  PRIMARY KEY ("id"),
  "created" date NOT NULL,
  "updated" date NOT NULL
);

CREATE TABLE "client" (
  "id" serial NOT NULL,
  PRIMARY KEY ("id"),
  "created" date NOT NULL,
  "updated" date NOT NULL,
  "ip" text NOT NULL,
  "name" text NOT NULL,
  "status" text NOT NULL
);
