create type "public"."project_status" as enum ('onboarding', 'in_progress', 'completed');

create table "public"."admin_invitations" (
    "id" uuid not null default gen_random_uuid(),
    "email" text not null,
    "token" text not null,
    "expires_at" timestamp with time zone not null,
    "created_at" timestamp with time zone default now(),
    "status" text default 'pending'::text,
    "accepted_at" timestamp with time zone,
    "invited_as" text default 'admin'::text
);


alter table "public"."admin_invitations" enable row level security;

create table "public"."admins" (
    "id" uuid not null,
    "email" text not null,
    "role" text default 'admin'::text,
    "status" text default 'active'::text,
    "created_at" timestamp with time zone default now()
);


alter table "public"."admins" enable row level security;

create table "public"."project_datas" (
    "id" uuid not null default gen_random_uuid(),
    "project_id" uuid not null,
    "week_number" integer,
    "day_number" integer,
    "type" character varying(20) not null,
    "link" text,
    "content" text not null,
    "created_at" timestamp with time zone not null default timezone('utc'::text, now()),
    "updated_at" timestamp with time zone not null default timezone('utc'::text, now()),
    "title" text not null default 'Untitled'::text,
    "status" text not null default 'draft'::text,
    "comments" text,
    "reviewer" text,
    "publish_status" text default 'stagging'::text
);


alter table "public"."project_datas" enable row level security;

create table "public"."projects" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "duration" text,
    "description" text,
    "position" text not null,
    "overview" text[],
    "industry" text,
    "tech_stack" text[],
    "demo_links" text[],
    "video_link" text,
    "pictures" text[],
    "deliverables" jsonb,
    "outcome" text,
    "created_at" timestamp with time zone default now(),
    "price" numeric,
    "background_information" text,
    "work_overview" text,
    "paypal_plan_id" text,
    "status" text not null default 'draft'::text,
    "reviewer" text,
    "comments" text,
    "publish_status" text default 'stagging'::text
);


alter table "public"."projects" enable row level security;

create table "public"."student_final_deliverables" (
    "id" uuid not null default gen_random_uuid(),
    "student_id" uuid not null,
    "project_id" uuid not null,
    "presentation_url" text,
    "presentation_file_name" text,
    "presentation_file_size" bigint,
    "demo_video_url" text,
    "demo_video_file_name" text,
    "demo_video_file_size" bigint,
    "status" character varying(20) default 'pending'::character varying,
    "uploaded_at" timestamp with time zone,
    "reviewed_at" timestamp with time zone,
    "reviewer_feedback" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."student_final_deliverables" enable row level security;

create table "public"."student_project_progress" (
    "id" uuid not null default gen_random_uuid(),
    "student_id" uuid not null,
    "project_id" uuid not null,
    "total_weeks" integer default 8,
    "completed_weeks" integer default 0,
    "weekly_uploads_completed" integer default 0,
    "final_deliverables_completed" boolean default false,
    "certificate_eligible" boolean default false,
    "certificate_generated" boolean default false,
    "certificate_url" text,
    "completion_percentage" numeric(5,2) default 0.00,
    "started_at" timestamp with time zone default now(),
    "completed_at" timestamp with time zone,
    "last_activity_at" timestamp with time zone default now(),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
);


alter table "public"."student_project_progress" enable row level security;

create table "public"."student_projects" (
    "id" uuid not null default gen_random_uuid(),
    "student_id" uuid,
    "project_id" uuid,
    "status" project_status default 'onboarding'::project_status,
    "joined_at" timestamp with time zone default now(),
    "payment_id" text,
    "subscription_id" uuid,
    "payment_status" text default 'not-paid'::text
);


alter table "public"."student_projects" enable row level security;

create table "public"."student_weekly_uploads" (
    "id" uuid not null default gen_random_uuid(),
    "student_id" uuid not null,
    "project_id" uuid not null,
    "week_number" integer not null,
    "summary" text not null,
    "video_url" text,
    "video_file_name" text,
    "video_file_size" bigint,
    "status" character varying(20) default 'pending'::character varying,
    "uploaded_at" timestamp with time zone,
    "reviewed_at" timestamp with time zone,
    "reviewer_feedback" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "code_url" text,
    "code_file_name" text,
    "code_file_size" integer,
    "video_status" text default 'pending'::text,
    "code_status" text default 'pending'::text
);


alter table "public"."student_weekly_uploads" enable row level security;

create table "public"."students" (
    "id" uuid not null,
    "email" text not null,
    "name" text not null,
    "school" text not null,
    "major" text not null,
    "country" text not null,
    "year_level" text not null,
    "resume_url" text,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "github_username" character varying(100),
    "has_used_free_trial" boolean not null default false
);


alter table "public"."students" enable row level security;

create table "public"."testMig" (
    "id" bigint generated by default as identity not null,
    "created_at" timestamp with time zone not null default now(),
    "userId" uuid
);


alter table "public"."testMig" enable row level security;

create table "public"."user_trials" (
    "id" bigint generated by default as identity not null,
    "user_id" uuid,
    "trial_start" timestamp with time zone,
    "created_at" timestamp with time zone not null default now(),
    "trial_project_id" uuid,
    "payment_method" text,
    "trial_end" timestamp with time zone,
    "trial_status" text default 'inactive'::text,
    "customer_id" text,
    "price" bigint default '0'::bigint
);


alter table "public"."user_trials" enable row level security;

CREATE UNIQUE INDEX admin_invitations_email_key ON public.admin_invitations USING btree (email);

CREATE UNIQUE INDEX admin_invitations_pkey ON public.admin_invitations USING btree (id);

CREATE UNIQUE INDEX admins_email_key ON public.admins USING btree (email);

CREATE UNIQUE INDEX admins_pkey ON public.admins USING btree (id);

CREATE INDEX idx_final_deliverables_status ON public.student_final_deliverables USING btree (status);

CREATE INDEX idx_final_deliverables_student_project ON public.student_final_deliverables USING btree (student_id, project_id);

CREATE INDEX idx_project_datas_day_number ON public.project_datas USING btree (day_number);

CREATE INDEX idx_project_datas_project_id ON public.project_datas USING btree (project_id);

CREATE INDEX idx_project_datas_type ON public.project_datas USING btree (type);

CREATE INDEX idx_project_datas_week_number ON public.project_datas USING btree (week_number);

CREATE INDEX idx_project_progress_eligible ON public.student_project_progress USING btree (certificate_eligible);

CREATE INDEX idx_project_progress_project ON public.student_project_progress USING btree (project_id);

CREATE INDEX idx_project_progress_student ON public.student_project_progress USING btree (student_id);

CREATE INDEX idx_student_project_project ON public.student_projects USING btree (project_id);

CREATE INDEX idx_student_project_status ON public.student_projects USING btree (status);

CREATE INDEX idx_student_project_student ON public.student_projects USING btree (student_id);

CREATE INDEX idx_weekly_uploads_status ON public.student_weekly_uploads USING btree (status);

CREATE INDEX idx_weekly_uploads_student_project ON public.student_weekly_uploads USING btree (student_id, project_id);

CREATE INDEX idx_weekly_uploads_week ON public.student_weekly_uploads USING btree (week_number);

CREATE UNIQUE INDEX project_datas_pkey ON public.project_datas USING btree (id);

CREATE UNIQUE INDEX projects_pkey ON public.projects USING btree (id);

CREATE UNIQUE INDEX student_final_deliverables_pkey ON public.student_final_deliverables USING btree (id);

CREATE UNIQUE INDEX student_final_deliverables_student_id_project_id_key ON public.student_final_deliverables USING btree (student_id, project_id);

CREATE UNIQUE INDEX student_project_progress_pkey ON public.student_project_progress USING btree (id);

CREATE UNIQUE INDEX student_project_progress_student_id_project_id_key ON public.student_project_progress USING btree (student_id, project_id);

CREATE UNIQUE INDEX student_projects_pkey ON public.student_projects USING btree (id);

CREATE UNIQUE INDEX student_weekly_uploads_pkey ON public.student_weekly_uploads USING btree (id);

CREATE UNIQUE INDEX student_weekly_uploads_student_id_project_id_week_number_key ON public.student_weekly_uploads USING btree (student_id, project_id, week_number);

CREATE UNIQUE INDEX students_email_key ON public.students USING btree (email);

CREATE UNIQUE INDEX students_pkey ON public.students USING btree (id);

CREATE UNIQUE INDEX "testMig_pkey" ON public."testMig" USING btree (id);

CREATE UNIQUE INDEX unique_student_project ON public.student_projects USING btree (student_id, project_id);

CREATE UNIQUE INDEX user_trials_customer_id_key ON public.user_trials USING btree (customer_id);

CREATE UNIQUE INDEX user_trials_pkey ON public.user_trials USING btree (id);

CREATE UNIQUE INDEX user_trials_user_id_key ON public.user_trials USING btree (user_id);

alter table "public"."admin_invitations" add constraint "admin_invitations_pkey" PRIMARY KEY using index "admin_invitations_pkey";

alter table "public"."admins" add constraint "admins_pkey" PRIMARY KEY using index "admins_pkey";

alter table "public"."project_datas" add constraint "project_datas_pkey" PRIMARY KEY using index "project_datas_pkey";

alter table "public"."projects" add constraint "projects_pkey" PRIMARY KEY using index "projects_pkey";

alter table "public"."student_final_deliverables" add constraint "student_final_deliverables_pkey" PRIMARY KEY using index "student_final_deliverables_pkey";

alter table "public"."student_project_progress" add constraint "student_project_progress_pkey" PRIMARY KEY using index "student_project_progress_pkey";

alter table "public"."student_projects" add constraint "student_projects_pkey" PRIMARY KEY using index "student_projects_pkey";

alter table "public"."student_weekly_uploads" add constraint "student_weekly_uploads_pkey" PRIMARY KEY using index "student_weekly_uploads_pkey";

alter table "public"."students" add constraint "students_pkey" PRIMARY KEY using index "students_pkey";

alter table "public"."testMig" add constraint "testMig_pkey" PRIMARY KEY using index "testMig_pkey";

alter table "public"."user_trials" add constraint "user_trials_pkey" PRIMARY KEY using index "user_trials_pkey";

alter table "public"."admin_invitations" add constraint "admin_invitations_email_key" UNIQUE using index "admin_invitations_email_key";

alter table "public"."admins" add constraint "admins_email_key" UNIQUE using index "admins_email_key";

alter table "public"."admins" add constraint "admins_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."admins" validate constraint "admins_id_fkey";

alter table "public"."project_datas" add constraint "project_datas_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."project_datas" validate constraint "project_datas_project_id_fkey";

alter table "public"."project_datas" add constraint "project_datas_status_check" CHECK ((status = ANY (ARRAY['draft'::text, 'under_review'::text, 'approved'::text, 'need_changes'::text]))) not valid;

alter table "public"."project_datas" validate constraint "project_datas_status_check";

alter table "public"."project_datas" add constraint "project_datas_type_check" CHECK (((type)::text = ANY (ARRAY[('day'::character varying)::text, ('week'::character varying)::text, ('dataset'::character varying)::text, ('general'::character varying)::text]))) not valid;

alter table "public"."project_datas" validate constraint "project_datas_type_check";

alter table "public"."projects" add constraint "projects_status_check" CHECK ((status = ANY (ARRAY['draft'::text, 'under_review'::text, 'approved'::text, 'need_changes'::text]))) not valid;

alter table "public"."projects" validate constraint "projects_status_check";

alter table "public"."student_final_deliverables" add constraint "student_final_deliverables_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE not valid;

alter table "public"."student_final_deliverables" validate constraint "student_final_deliverables_project_id_fkey";

alter table "public"."student_final_deliverables" add constraint "student_final_deliverables_status_check" CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('uploaded'::character varying)::text, ('reviewed'::character varying)::text]))) not valid;

alter table "public"."student_final_deliverables" validate constraint "student_final_deliverables_status_check";

alter table "public"."student_final_deliverables" add constraint "student_final_deliverables_student_id_fkey" FOREIGN KEY (student_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."student_final_deliverables" validate constraint "student_final_deliverables_student_id_fkey";

alter table "public"."student_final_deliverables" add constraint "student_final_deliverables_student_id_project_id_key" UNIQUE using index "student_final_deliverables_student_id_project_id_key";

alter table "public"."student_project_progress" add constraint "student_project_progress_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE not valid;

alter table "public"."student_project_progress" validate constraint "student_project_progress_project_id_fkey";

alter table "public"."student_project_progress" add constraint "student_project_progress_student_id_fkey" FOREIGN KEY (student_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."student_project_progress" validate constraint "student_project_progress_student_id_fkey";

alter table "public"."student_project_progress" add constraint "student_project_progress_student_id_project_id_key" UNIQUE using index "student_project_progress_student_id_project_id_key";

alter table "public"."student_projects" add constraint "student_projects_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE not valid;

alter table "public"."student_projects" validate constraint "student_projects_project_id_fkey";

alter table "public"."student_projects" add constraint "student_projects_student_id_fkey" FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE not valid;

alter table "public"."student_projects" validate constraint "student_projects_student_id_fkey";

alter table "public"."student_projects" add constraint "unique_student_project" UNIQUE using index "unique_student_project";

alter table "public"."student_weekly_uploads" add constraint "student_weekly_uploads_project_id_fkey" FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE not valid;

alter table "public"."student_weekly_uploads" validate constraint "student_weekly_uploads_project_id_fkey";

alter table "public"."student_weekly_uploads" add constraint "student_weekly_uploads_status_check" CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('uploaded'::character varying)::text, ('reviewed'::character varying)::text]))) not valid;

alter table "public"."student_weekly_uploads" validate constraint "student_weekly_uploads_status_check";

alter table "public"."student_weekly_uploads" add constraint "student_weekly_uploads_student_id_fkey" FOREIGN KEY (student_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."student_weekly_uploads" validate constraint "student_weekly_uploads_student_id_fkey";

alter table "public"."student_weekly_uploads" add constraint "student_weekly_uploads_student_id_project_id_week_number_key" UNIQUE using index "student_weekly_uploads_student_id_project_id_week_number_key";

alter table "public"."student_weekly_uploads" add constraint "student_weekly_uploads_week_number_check" CHECK (((week_number >= 1) AND (week_number <= 8))) not valid;

alter table "public"."student_weekly_uploads" validate constraint "student_weekly_uploads_week_number_check";

alter table "public"."students" add constraint "students_email_key" UNIQUE using index "students_email_key";

alter table "public"."students" add constraint "students_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."students" validate constraint "students_id_fkey";

alter table "public"."user_trials" add constraint "user_trials_customer_id_key" UNIQUE using index "user_trials_customer_id_key";

alter table "public"."user_trials" add constraint "user_trials_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) not valid;

alter table "public"."user_trials" validate constraint "user_trials_user_id_fkey";

alter table "public"."user_trials" add constraint "user_trials_user_id_key" UNIQUE using index "user_trials_user_id_key";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.check_student_email_exists(input_email text)
 RETURNS boolean
 LANGUAGE sql
 SECURITY DEFINER
AS $function$
  SELECT EXISTS (
    SELECT 1 FROM students WHERE email = input_email
  );
$function$
;

CREATE OR REPLACE FUNCTION public.get_admin_role(uid uuid)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  r text;
BEGIN
  -- Bypass RLS using SECURITY DEFINER
  SELECT role INTO r FROM admins WHERE id = uid;
  RETURN r;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;$function$
;

grant delete on table "public"."admin_invitations" to "anon";

grant insert on table "public"."admin_invitations" to "anon";

grant references on table "public"."admin_invitations" to "anon";

grant select on table "public"."admin_invitations" to "anon";

grant trigger on table "public"."admin_invitations" to "anon";

grant truncate on table "public"."admin_invitations" to "anon";

grant update on table "public"."admin_invitations" to "anon";

grant delete on table "public"."admin_invitations" to "authenticated";

grant insert on table "public"."admin_invitations" to "authenticated";

grant references on table "public"."admin_invitations" to "authenticated";

grant select on table "public"."admin_invitations" to "authenticated";

grant trigger on table "public"."admin_invitations" to "authenticated";

grant truncate on table "public"."admin_invitations" to "authenticated";

grant update on table "public"."admin_invitations" to "authenticated";

grant delete on table "public"."admin_invitations" to "service_role";

grant insert on table "public"."admin_invitations" to "service_role";

grant references on table "public"."admin_invitations" to "service_role";

grant select on table "public"."admin_invitations" to "service_role";

grant trigger on table "public"."admin_invitations" to "service_role";

grant truncate on table "public"."admin_invitations" to "service_role";

grant update on table "public"."admin_invitations" to "service_role";

grant delete on table "public"."admins" to "anon";

grant insert on table "public"."admins" to "anon";

grant references on table "public"."admins" to "anon";

grant select on table "public"."admins" to "anon";

grant trigger on table "public"."admins" to "anon";

grant truncate on table "public"."admins" to "anon";

grant update on table "public"."admins" to "anon";

grant delete on table "public"."admins" to "authenticated";

grant insert on table "public"."admins" to "authenticated";

grant references on table "public"."admins" to "authenticated";

grant select on table "public"."admins" to "authenticated";

grant trigger on table "public"."admins" to "authenticated";

grant truncate on table "public"."admins" to "authenticated";

grant update on table "public"."admins" to "authenticated";

grant delete on table "public"."admins" to "service_role";

grant insert on table "public"."admins" to "service_role";

grant references on table "public"."admins" to "service_role";

grant select on table "public"."admins" to "service_role";

grant trigger on table "public"."admins" to "service_role";

grant truncate on table "public"."admins" to "service_role";

grant update on table "public"."admins" to "service_role";

grant delete on table "public"."project_datas" to "anon";

grant insert on table "public"."project_datas" to "anon";

grant references on table "public"."project_datas" to "anon";

grant select on table "public"."project_datas" to "anon";

grant trigger on table "public"."project_datas" to "anon";

grant truncate on table "public"."project_datas" to "anon";

grant update on table "public"."project_datas" to "anon";

grant delete on table "public"."project_datas" to "authenticated";

grant insert on table "public"."project_datas" to "authenticated";

grant references on table "public"."project_datas" to "authenticated";

grant select on table "public"."project_datas" to "authenticated";

grant trigger on table "public"."project_datas" to "authenticated";

grant truncate on table "public"."project_datas" to "authenticated";

grant update on table "public"."project_datas" to "authenticated";

grant delete on table "public"."project_datas" to "service_role";

grant insert on table "public"."project_datas" to "service_role";

grant references on table "public"."project_datas" to "service_role";

grant select on table "public"."project_datas" to "service_role";

grant trigger on table "public"."project_datas" to "service_role";

grant truncate on table "public"."project_datas" to "service_role";

grant update on table "public"."project_datas" to "service_role";

grant delete on table "public"."projects" to "anon";

grant insert on table "public"."projects" to "anon";

grant references on table "public"."projects" to "anon";

grant select on table "public"."projects" to "anon";

grant trigger on table "public"."projects" to "anon";

grant truncate on table "public"."projects" to "anon";

grant update on table "public"."projects" to "anon";

grant delete on table "public"."projects" to "authenticated";

grant insert on table "public"."projects" to "authenticated";

grant references on table "public"."projects" to "authenticated";

grant select on table "public"."projects" to "authenticated";

grant trigger on table "public"."projects" to "authenticated";

grant truncate on table "public"."projects" to "authenticated";

grant update on table "public"."projects" to "authenticated";

grant delete on table "public"."projects" to "service_role";

grant insert on table "public"."projects" to "service_role";

grant references on table "public"."projects" to "service_role";

grant select on table "public"."projects" to "service_role";

grant trigger on table "public"."projects" to "service_role";

grant truncate on table "public"."projects" to "service_role";

grant update on table "public"."projects" to "service_role";

grant delete on table "public"."student_final_deliverables" to "anon";

grant insert on table "public"."student_final_deliverables" to "anon";

grant references on table "public"."student_final_deliverables" to "anon";

grant select on table "public"."student_final_deliverables" to "anon";

grant trigger on table "public"."student_final_deliverables" to "anon";

grant truncate on table "public"."student_final_deliverables" to "anon";

grant update on table "public"."student_final_deliverables" to "anon";

grant delete on table "public"."student_final_deliverables" to "authenticated";

grant insert on table "public"."student_final_deliverables" to "authenticated";

grant references on table "public"."student_final_deliverables" to "authenticated";

grant select on table "public"."student_final_deliverables" to "authenticated";

grant trigger on table "public"."student_final_deliverables" to "authenticated";

grant truncate on table "public"."student_final_deliverables" to "authenticated";

grant update on table "public"."student_final_deliverables" to "authenticated";

grant delete on table "public"."student_final_deliverables" to "service_role";

grant insert on table "public"."student_final_deliverables" to "service_role";

grant references on table "public"."student_final_deliverables" to "service_role";

grant select on table "public"."student_final_deliverables" to "service_role";

grant trigger on table "public"."student_final_deliverables" to "service_role";

grant truncate on table "public"."student_final_deliverables" to "service_role";

grant update on table "public"."student_final_deliverables" to "service_role";

grant delete on table "public"."student_project_progress" to "anon";

grant insert on table "public"."student_project_progress" to "anon";

grant references on table "public"."student_project_progress" to "anon";

grant select on table "public"."student_project_progress" to "anon";

grant trigger on table "public"."student_project_progress" to "anon";

grant truncate on table "public"."student_project_progress" to "anon";

grant update on table "public"."student_project_progress" to "anon";

grant delete on table "public"."student_project_progress" to "authenticated";

grant insert on table "public"."student_project_progress" to "authenticated";

grant references on table "public"."student_project_progress" to "authenticated";

grant select on table "public"."student_project_progress" to "authenticated";

grant trigger on table "public"."student_project_progress" to "authenticated";

grant truncate on table "public"."student_project_progress" to "authenticated";

grant update on table "public"."student_project_progress" to "authenticated";

grant delete on table "public"."student_project_progress" to "service_role";

grant insert on table "public"."student_project_progress" to "service_role";

grant references on table "public"."student_project_progress" to "service_role";

grant select on table "public"."student_project_progress" to "service_role";

grant trigger on table "public"."student_project_progress" to "service_role";

grant truncate on table "public"."student_project_progress" to "service_role";

grant update on table "public"."student_project_progress" to "service_role";

grant delete on table "public"."student_projects" to "anon";

grant insert on table "public"."student_projects" to "anon";

grant references on table "public"."student_projects" to "anon";

grant select on table "public"."student_projects" to "anon";

grant trigger on table "public"."student_projects" to "anon";

grant truncate on table "public"."student_projects" to "anon";

grant update on table "public"."student_projects" to "anon";

grant delete on table "public"."student_projects" to "authenticated";

grant insert on table "public"."student_projects" to "authenticated";

grant references on table "public"."student_projects" to "authenticated";

grant select on table "public"."student_projects" to "authenticated";

grant trigger on table "public"."student_projects" to "authenticated";

grant truncate on table "public"."student_projects" to "authenticated";

grant update on table "public"."student_projects" to "authenticated";

grant delete on table "public"."student_projects" to "service_role";

grant insert on table "public"."student_projects" to "service_role";

grant references on table "public"."student_projects" to "service_role";

grant select on table "public"."student_projects" to "service_role";

grant trigger on table "public"."student_projects" to "service_role";

grant truncate on table "public"."student_projects" to "service_role";

grant update on table "public"."student_projects" to "service_role";

grant delete on table "public"."student_weekly_uploads" to "anon";

grant insert on table "public"."student_weekly_uploads" to "anon";

grant references on table "public"."student_weekly_uploads" to "anon";

grant select on table "public"."student_weekly_uploads" to "anon";

grant trigger on table "public"."student_weekly_uploads" to "anon";

grant truncate on table "public"."student_weekly_uploads" to "anon";

grant update on table "public"."student_weekly_uploads" to "anon";

grant delete on table "public"."student_weekly_uploads" to "authenticated";

grant insert on table "public"."student_weekly_uploads" to "authenticated";

grant references on table "public"."student_weekly_uploads" to "authenticated";

grant select on table "public"."student_weekly_uploads" to "authenticated";

grant trigger on table "public"."student_weekly_uploads" to "authenticated";

grant truncate on table "public"."student_weekly_uploads" to "authenticated";

grant update on table "public"."student_weekly_uploads" to "authenticated";

grant delete on table "public"."student_weekly_uploads" to "service_role";

grant insert on table "public"."student_weekly_uploads" to "service_role";

grant references on table "public"."student_weekly_uploads" to "service_role";

grant select on table "public"."student_weekly_uploads" to "service_role";

grant trigger on table "public"."student_weekly_uploads" to "service_role";

grant truncate on table "public"."student_weekly_uploads" to "service_role";

grant update on table "public"."student_weekly_uploads" to "service_role";

grant delete on table "public"."students" to "anon";

grant insert on table "public"."students" to "anon";

grant references on table "public"."students" to "anon";

grant select on table "public"."students" to "anon";

grant trigger on table "public"."students" to "anon";

grant truncate on table "public"."students" to "anon";

grant update on table "public"."students" to "anon";

grant delete on table "public"."students" to "authenticated";

grant insert on table "public"."students" to "authenticated";

grant references on table "public"."students" to "authenticated";

grant select on table "public"."students" to "authenticated";

grant trigger on table "public"."students" to "authenticated";

grant truncate on table "public"."students" to "authenticated";

grant update on table "public"."students" to "authenticated";

grant delete on table "public"."students" to "service_role";

grant insert on table "public"."students" to "service_role";

grant references on table "public"."students" to "service_role";

grant select on table "public"."students" to "service_role";

grant trigger on table "public"."students" to "service_role";

grant truncate on table "public"."students" to "service_role";

grant update on table "public"."students" to "service_role";

grant delete on table "public"."testMig" to "anon";

grant insert on table "public"."testMig" to "anon";

grant references on table "public"."testMig" to "anon";

grant select on table "public"."testMig" to "anon";

grant trigger on table "public"."testMig" to "anon";

grant truncate on table "public"."testMig" to "anon";

grant update on table "public"."testMig" to "anon";

grant delete on table "public"."testMig" to "authenticated";

grant insert on table "public"."testMig" to "authenticated";

grant references on table "public"."testMig" to "authenticated";

grant select on table "public"."testMig" to "authenticated";

grant trigger on table "public"."testMig" to "authenticated";

grant truncate on table "public"."testMig" to "authenticated";

grant update on table "public"."testMig" to "authenticated";

grant delete on table "public"."testMig" to "service_role";

grant insert on table "public"."testMig" to "service_role";

grant references on table "public"."testMig" to "service_role";

grant select on table "public"."testMig" to "service_role";

grant trigger on table "public"."testMig" to "service_role";

grant truncate on table "public"."testMig" to "service_role";

grant update on table "public"."testMig" to "service_role";

grant delete on table "public"."user_trials" to "anon";

grant insert on table "public"."user_trials" to "anon";

grant references on table "public"."user_trials" to "anon";

grant select on table "public"."user_trials" to "anon";

grant trigger on table "public"."user_trials" to "anon";

grant truncate on table "public"."user_trials" to "anon";

grant update on table "public"."user_trials" to "anon";

grant delete on table "public"."user_trials" to "authenticated";

grant insert on table "public"."user_trials" to "authenticated";

grant references on table "public"."user_trials" to "authenticated";

grant select on table "public"."user_trials" to "authenticated";

grant trigger on table "public"."user_trials" to "authenticated";

grant truncate on table "public"."user_trials" to "authenticated";

grant update on table "public"."user_trials" to "authenticated";

grant delete on table "public"."user_trials" to "service_role";

grant insert on table "public"."user_trials" to "service_role";

grant references on table "public"."user_trials" to "service_role";

grant select on table "public"."user_trials" to "service_role";

grant trigger on table "public"."user_trials" to "service_role";

grant truncate on table "public"."user_trials" to "service_role";

grant update on table "public"."user_trials" to "service_role";

create policy "Allow read access for authenticated admins"
on "public"."admin_invitations"
as permissive
for select
to public
using (((auth.role() = 'authenticated'::text) AND (get_admin_role(auth.uid()) = ANY (ARRAY['superadmin'::text, 'admin'::text, 'reviewer'::text]))));


create policy "Superadmin delete only"
on "public"."admin_invitations"
as permissive
for delete
to public
using (((auth.role() = 'authenticated'::text) AND (get_admin_role(auth.uid()) = 'superadmin'::text)));


create policy "Superadmin insert only"
on "public"."admin_invitations"
as permissive
for insert
to public
with check (((auth.role() = 'authenticated'::text) AND (get_admin_role(auth.uid()) = 'superadmin'::text)));


create policy "Superadmin update only"
on "public"."admin_invitations"
as permissive
for update
to public
using (((auth.role() = 'authenticated'::text) AND (get_admin_role(auth.uid()) = 'superadmin'::text)));


create policy "Allow read access for authenticated admins"
on "public"."admins"
as permissive
for select
to public
using (((auth.role() = 'authenticated'::text) AND (get_admin_role(auth.uid()) = ANY (ARRAY['superadmin'::text, 'admin'::text, 'reviewer'::text]))));


create policy "Superadmin delete only"
on "public"."admins"
as permissive
for delete
to public
using (((auth.role() = 'authenticated'::text) AND (get_admin_role(auth.uid()) = 'superadmin'::text)));


create policy "Superadmin insert only"
on "public"."admins"
as permissive
for insert
to public
with check (((auth.role() = 'authenticated'::text) AND (get_admin_role(auth.uid()) = 'superadmin'::text)));


create policy "Superadmin update only"
on "public"."admins"
as permissive
for update
to public
using (((auth.role() = 'authenticated'::text) AND (get_admin_role(auth.uid()) = 'superadmin'::text)));


create policy "Allow delete for admin and superadmin"
on "public"."project_datas"
as permissive
for delete
to public
using (((auth.role() = 'authenticated'::text) AND (get_admin_role(auth.uid()) = ANY (ARRAY['superadmin'::text, 'admin'::text]))));


create policy "Allow insert for admin and superadmin"
on "public"."project_datas"
as permissive
for insert
to public
with check (((auth.role() = 'authenticated'::text) AND (get_admin_role(auth.uid()) = ANY (ARRAY['superadmin'::text, 'admin'::text]))));


create policy "Allow read access for all users"
on "public"."project_datas"
as permissive
for select
to public
using (true);


create policy "Allow update for admin, reviewer and superadmin"
on "public"."project_datas"
as permissive
for update
to public
using (((auth.role() = 'authenticated'::text) AND (get_admin_role(auth.uid()) = ANY (ARRAY['superadmin'::text, 'admin'::text, 'reviewer'::text]))));


create policy "Allow delete for admin and superadmin"
on "public"."projects"
as permissive
for delete
to public
using (((auth.role() = 'authenticated'::text) AND (get_admin_role(auth.uid()) = ANY (ARRAY['superadmin'::text, 'admin'::text]))));


create policy "Allow insert for admin and superadmin"
on "public"."projects"
as permissive
for insert
to public
with check (((auth.role() = 'authenticated'::text) AND (get_admin_role(auth.uid()) = ANY (ARRAY['superadmin'::text, 'admin'::text]))));


create policy "Allow read access for all users"
on "public"."projects"
as permissive
for select
to public
using (true);


create policy "Allow update for admin, reviewer and superadmin"
on "public"."projects"
as permissive
for update
to public
using (((auth.role() = 'authenticated'::text) AND (get_admin_role(auth.uid()) = ANY (ARRAY['superadmin'::text, 'admin'::text, 'reviewer'::text]))));


create policy "Delete own deliverable"
on "public"."student_final_deliverables"
as permissive
for delete
to public
using ((auth.uid() = student_id));


create policy "Insert own deliverable"
on "public"."student_final_deliverables"
as permissive
for insert
to public
with check ((auth.uid() = student_id));


create policy "Read own deliverables"
on "public"."student_final_deliverables"
as permissive
for select
to public
using ((auth.uid() = student_id));


create policy "Update own deliverable"
on "public"."student_final_deliverables"
as permissive
for update
to public
using ((auth.uid() = student_id));


create policy "Delete own progress"
on "public"."student_project_progress"
as permissive
for delete
to public
using ((auth.uid() = student_id));


create policy "Insert own progress"
on "public"."student_project_progress"
as permissive
for insert
to public
with check ((auth.uid() = student_id));


create policy "Read own progress"
on "public"."student_project_progress"
as permissive
for select
to public
using ((auth.uid() = student_id));


create policy "Update own progress"
on "public"."student_project_progress"
as permissive
for update
to public
using ((auth.uid() = student_id));


create policy "Students can delete their project links"
on "public"."student_projects"
as permissive
for delete
to public
using ((auth.uid() = student_id));


create policy "Students can insert their project links"
on "public"."student_projects"
as permissive
for insert
to public
with check ((auth.uid() = student_id));


create policy "Students can read their project links"
on "public"."student_projects"
as permissive
for select
to public
using ((auth.uid() = student_id));


create policy "Students can update their project links"
on "public"."student_projects"
as permissive
for update
to public
using ((auth.uid() = student_id));


create policy "Delete own weekly upload"
on "public"."student_weekly_uploads"
as permissive
for delete
to public
using ((auth.uid() = student_id));


create policy "Insert own weekly upload"
on "public"."student_weekly_uploads"
as permissive
for insert
to public
with check ((auth.uid() = student_id));


create policy "Read own weekly uploads"
on "public"."student_weekly_uploads"
as permissive
for select
to public
using ((auth.uid() = student_id));


create policy "Update own weekly upload"
on "public"."student_weekly_uploads"
as permissive
for update
to public
using ((auth.uid() = student_id));


create policy "Students can insert their own profile"
on "public"."students"
as permissive
for insert
to public
with check ((auth.uid() = id));


create policy "Students can read their own profile"
on "public"."students"
as permissive
for select
to public
using ((auth.uid() = id));


create policy "Students can update their own profile"
on "public"."students"
as permissive
for update
to public
using ((auth.uid() = id));


create policy "Insert own trial record"
on "public"."user_trials"
as permissive
for insert
to public
with check ((auth.uid() = user_id));


create policy "Read own trial status"
on "public"."user_trials"
as permissive
for select
to public
using ((auth.uid() = user_id));


create policy "Update own trial record"
on "public"."user_trials"
as permissive
for update
to public
using ((auth.uid() = user_id));


CREATE TRIGGER update_project_datas_updated_at BEFORE UPDATE ON public.project_datas FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();



