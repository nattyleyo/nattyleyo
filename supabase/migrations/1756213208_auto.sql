revoke delete on table "public"."testMig" from "anon";

revoke insert on table "public"."testMig" from "anon";

revoke references on table "public"."testMig" from "anon";

revoke select on table "public"."testMig" from "anon";

revoke trigger on table "public"."testMig" from "anon";

revoke truncate on table "public"."testMig" from "anon";

revoke update on table "public"."testMig" from "anon";

revoke delete on table "public"."testMig" from "authenticated";

revoke insert on table "public"."testMig" from "authenticated";

revoke references on table "public"."testMig" from "authenticated";

revoke select on table "public"."testMig" from "authenticated";

revoke trigger on table "public"."testMig" from "authenticated";

revoke truncate on table "public"."testMig" from "authenticated";

revoke update on table "public"."testMig" from "authenticated";

revoke delete on table "public"."testMig" from "service_role";

revoke insert on table "public"."testMig" from "service_role";

revoke references on table "public"."testMig" from "service_role";

revoke select on table "public"."testMig" from "service_role";

revoke trigger on table "public"."testMig" from "service_role";

revoke truncate on table "public"."testMig" from "service_role";

revoke update on table "public"."testMig" from "service_role";

alter table "public"."testMig" drop constraint "testMig_pkey";

drop index if exists "public"."testMig_pkey";

drop table "public"."testMig";
