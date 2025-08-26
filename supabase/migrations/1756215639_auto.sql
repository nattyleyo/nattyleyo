create table "public"."myTest" (
    "created_at" timestamp with time zone not null default now(),
    "value" real
);


alter table "public"."myTest" enable row level security;

grant delete on table "public"."myTest" to "anon";

grant insert on table "public"."myTest" to "anon";

grant references on table "public"."myTest" to "anon";

grant select on table "public"."myTest" to "anon";

grant trigger on table "public"."myTest" to "anon";

grant truncate on table "public"."myTest" to "anon";

grant update on table "public"."myTest" to "anon";

grant delete on table "public"."myTest" to "authenticated";

grant insert on table "public"."myTest" to "authenticated";

grant references on table "public"."myTest" to "authenticated";

grant select on table "public"."myTest" to "authenticated";

grant trigger on table "public"."myTest" to "authenticated";

grant truncate on table "public"."myTest" to "authenticated";

grant update on table "public"."myTest" to "authenticated";

grant delete on table "public"."myTest" to "service_role";

grant insert on table "public"."myTest" to "service_role";

grant references on table "public"."myTest" to "service_role";

grant select on table "public"."myTest" to "service_role";

grant trigger on table "public"."myTest" to "service_role";

grant truncate on table "public"."myTest" to "service_role";

grant update on table "public"."myTest" to "service_role";
