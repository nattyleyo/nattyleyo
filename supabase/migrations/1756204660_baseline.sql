

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."project_status" AS ENUM (
    'onboarding',
    'in_progress',
    'completed'
);


ALTER TYPE "public"."project_status" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."check_student_email_exists"("input_email" "text") RETURNS boolean
    LANGUAGE "sql" SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM students WHERE email = input_email
  );
$$;


ALTER FUNCTION "public"."check_student_email_exists"("input_email" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_admin_role"("uid" "uuid") RETURNS "text"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
  r text;
BEGIN
  -- Bypass RLS using SECURITY DEFINER
  SELECT role INTO r FROM admins WHERE id = uid;
  RETURN r;
END;
$$;


ALTER FUNCTION "public"."get_admin_role"("uid" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;$$;


ALTER FUNCTION "public"."update_updated_at_column"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."admin_invitations" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "email" "text" NOT NULL,
    "token" "text" NOT NULL,
    "expires_at" timestamp with time zone NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "status" "text" DEFAULT 'pending'::"text",
    "accepted_at" timestamp with time zone,
    "invited_as" "text" DEFAULT 'admin'::"text"
);


ALTER TABLE "public"."admin_invitations" OWNER TO "postgres";


COMMENT ON COLUMN "public"."admin_invitations"."status" IS 'pending';



CREATE TABLE IF NOT EXISTS "public"."admins" (
    "id" "uuid" NOT NULL,
    "email" "text" NOT NULL,
    "role" "text" DEFAULT 'admin'::"text",
    "status" "text" DEFAULT 'active'::"text",
    "created_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."admins" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."project_datas" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "project_id" "uuid" NOT NULL,
    "week_number" integer,
    "day_number" integer,
    "type" character varying(20) NOT NULL,
    "link" "text",
    "content" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL,
    "title" "text" DEFAULT 'Untitled'::"text" NOT NULL,
    "status" "text" DEFAULT 'draft'::"text" NOT NULL,
    "comments" "text",
    "reviewer" "text",
    "publish_status" "text" DEFAULT 'stagging'::"text",
    CONSTRAINT "project_datas_status_check" CHECK (("status" = ANY (ARRAY['draft'::"text", 'under_review'::"text", 'approved'::"text", 'need_changes'::"text"]))),
    CONSTRAINT "project_datas_type_check" CHECK ((("type")::"text" = ANY (ARRAY[('day'::character varying)::"text", ('week'::character varying)::"text", ('dataset'::character varying)::"text", ('general'::character varying)::"text"])))
);


ALTER TABLE "public"."project_datas" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."projects" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "name" "text" NOT NULL,
    "duration" "text",
    "description" "text",
    "position" "text" NOT NULL,
    "overview" "text"[],
    "industry" "text",
    "tech_stack" "text"[],
    "demo_links" "text"[],
    "video_link" "text",
    "pictures" "text"[],
    "deliverables" "jsonb",
    "outcome" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "price" numeric,
    "background_information" "text",
    "work_overview" "text",
    "paypal_plan_id" "text",
    "status" "text" DEFAULT 'draft'::"text" NOT NULL,
    "reviewer" "text",
    "comments" "text",
    "publish_status" "text" DEFAULT 'stagging'::"text",
    CONSTRAINT "projects_status_check" CHECK (("status" = ANY (ARRAY['draft'::"text", 'under_review'::"text", 'approved'::"text", 'need_changes'::"text"])))
);


ALTER TABLE "public"."projects" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."student_final_deliverables" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "student_id" "uuid" NOT NULL,
    "project_id" "uuid" NOT NULL,
    "presentation_url" "text",
    "presentation_file_name" "text",
    "presentation_file_size" bigint,
    "demo_video_url" "text",
    "demo_video_file_name" "text",
    "demo_video_file_size" bigint,
    "status" character varying(20) DEFAULT 'pending'::character varying,
    "uploaded_at" timestamp with time zone,
    "reviewed_at" timestamp with time zone,
    "reviewer_feedback" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "student_final_deliverables_status_check" CHECK ((("status")::"text" = ANY (ARRAY[('pending'::character varying)::"text", ('uploaded'::character varying)::"text", ('reviewed'::character varying)::"text"])))
);


ALTER TABLE "public"."student_final_deliverables" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."student_project_progress" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "student_id" "uuid" NOT NULL,
    "project_id" "uuid" NOT NULL,
    "total_weeks" integer DEFAULT 8,
    "completed_weeks" integer DEFAULT 0,
    "weekly_uploads_completed" integer DEFAULT 0,
    "final_deliverables_completed" boolean DEFAULT false,
    "certificate_eligible" boolean DEFAULT false,
    "certificate_generated" boolean DEFAULT false,
    "certificate_url" "text",
    "completion_percentage" numeric(5,2) DEFAULT 0.00,
    "started_at" timestamp with time zone DEFAULT "now"(),
    "completed_at" timestamp with time zone,
    "last_activity_at" timestamp with time zone DEFAULT "now"(),
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."student_project_progress" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."student_projects" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "student_id" "uuid",
    "project_id" "uuid",
    "status" "public"."project_status" DEFAULT 'onboarding'::"public"."project_status",
    "joined_at" timestamp with time zone DEFAULT "now"(),
    "payment_id" "text",
    "subscription_id" "uuid",
    "payment_status" "text" DEFAULT 'not-paid'::"text"
);


ALTER TABLE "public"."student_projects" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."student_weekly_uploads" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "student_id" "uuid" NOT NULL,
    "project_id" "uuid" NOT NULL,
    "week_number" integer NOT NULL,
    "summary" "text" NOT NULL,
    "video_url" "text",
    "video_file_name" "text",
    "video_file_size" bigint,
    "status" character varying(20) DEFAULT 'pending'::character varying,
    "uploaded_at" timestamp with time zone,
    "reviewed_at" timestamp with time zone,
    "reviewer_feedback" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "code_url" "text",
    "code_file_name" "text",
    "code_file_size" integer,
    "video_status" "text" DEFAULT 'pending'::"text",
    "code_status" "text" DEFAULT 'pending'::"text",
    CONSTRAINT "student_weekly_uploads_status_check" CHECK ((("status")::"text" = ANY (ARRAY[('pending'::character varying)::"text", ('uploaded'::character varying)::"text", ('reviewed'::character varying)::"text"]))),
    CONSTRAINT "student_weekly_uploads_week_number_check" CHECK ((("week_number" >= 1) AND ("week_number" <= 8)))
);


ALTER TABLE "public"."student_weekly_uploads" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."students" (
    "id" "uuid" NOT NULL,
    "email" "text" NOT NULL,
    "name" "text" NOT NULL,
    "school" "text" NOT NULL,
    "major" "text" NOT NULL,
    "country" "text" NOT NULL,
    "year_level" "text" NOT NULL,
    "resume_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "github_username" character varying(100),
    "has_used_free_trial" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."students" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."testMig" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "userId" "uuid",
    "test" "text"
);


ALTER TABLE "public"."testMig" OWNER TO "postgres";


ALTER TABLE "public"."testMig" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."testMig_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."user_trials" (
    "id" bigint NOT NULL,
    "user_id" "uuid",
    "trial_start" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "trial_project_id" "uuid",
    "payment_method" "text",
    "trial_end" timestamp with time zone,
    "trial_status" "text" DEFAULT 'inactive'::"text",
    "customer_id" "text",
    "price" bigint DEFAULT '0'::bigint
);


ALTER TABLE "public"."user_trials" OWNER TO "postgres";


ALTER TABLE "public"."user_trials" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."user_trials_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE ONLY "public"."admin_invitations"
    ADD CONSTRAINT "admin_invitations_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."admin_invitations"
    ADD CONSTRAINT "admin_invitations_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."admins"
    ADD CONSTRAINT "admins_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."admins"
    ADD CONSTRAINT "admins_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."project_datas"
    ADD CONSTRAINT "project_datas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."projects"
    ADD CONSTRAINT "projects_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."student_final_deliverables"
    ADD CONSTRAINT "student_final_deliverables_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."student_final_deliverables"
    ADD CONSTRAINT "student_final_deliverables_student_id_project_id_key" UNIQUE ("student_id", "project_id");



ALTER TABLE ONLY "public"."student_project_progress"
    ADD CONSTRAINT "student_project_progress_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."student_project_progress"
    ADD CONSTRAINT "student_project_progress_student_id_project_id_key" UNIQUE ("student_id", "project_id");



ALTER TABLE ONLY "public"."student_projects"
    ADD CONSTRAINT "student_projects_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."student_weekly_uploads"
    ADD CONSTRAINT "student_weekly_uploads_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."student_weekly_uploads"
    ADD CONSTRAINT "student_weekly_uploads_student_id_project_id_week_number_key" UNIQUE ("student_id", "project_id", "week_number");



ALTER TABLE ONLY "public"."students"
    ADD CONSTRAINT "students_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."students"
    ADD CONSTRAINT "students_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."testMig"
    ADD CONSTRAINT "testMig_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."student_projects"
    ADD CONSTRAINT "unique_student_project" UNIQUE ("student_id", "project_id");



ALTER TABLE ONLY "public"."user_trials"
    ADD CONSTRAINT "user_trials_customer_id_key" UNIQUE ("customer_id");



ALTER TABLE ONLY "public"."user_trials"
    ADD CONSTRAINT "user_trials_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."user_trials"
    ADD CONSTRAINT "user_trials_user_id_key" UNIQUE ("user_id");



CREATE INDEX "idx_final_deliverables_status" ON "public"."student_final_deliverables" USING "btree" ("status");



CREATE INDEX "idx_final_deliverables_student_project" ON "public"."student_final_deliverables" USING "btree" ("student_id", "project_id");



CREATE INDEX "idx_project_datas_day_number" ON "public"."project_datas" USING "btree" ("day_number");



CREATE INDEX "idx_project_datas_project_id" ON "public"."project_datas" USING "btree" ("project_id");



CREATE INDEX "idx_project_datas_type" ON "public"."project_datas" USING "btree" ("type");



CREATE INDEX "idx_project_datas_week_number" ON "public"."project_datas" USING "btree" ("week_number");



CREATE INDEX "idx_project_progress_eligible" ON "public"."student_project_progress" USING "btree" ("certificate_eligible");



CREATE INDEX "idx_project_progress_project" ON "public"."student_project_progress" USING "btree" ("project_id");



CREATE INDEX "idx_project_progress_student" ON "public"."student_project_progress" USING "btree" ("student_id");



CREATE INDEX "idx_student_project_project" ON "public"."student_projects" USING "btree" ("project_id");



CREATE INDEX "idx_student_project_status" ON "public"."student_projects" USING "btree" ("status");



CREATE INDEX "idx_student_project_student" ON "public"."student_projects" USING "btree" ("student_id");



CREATE INDEX "idx_weekly_uploads_status" ON "public"."student_weekly_uploads" USING "btree" ("status");



CREATE INDEX "idx_weekly_uploads_student_project" ON "public"."student_weekly_uploads" USING "btree" ("student_id", "project_id");



CREATE INDEX "idx_weekly_uploads_week" ON "public"."student_weekly_uploads" USING "btree" ("week_number");



CREATE OR REPLACE TRIGGER "update_project_datas_updated_at" BEFORE UPDATE ON "public"."project_datas" FOR EACH ROW EXECUTE FUNCTION "public"."update_updated_at_column"();



ALTER TABLE ONLY "public"."admins"
    ADD CONSTRAINT "admins_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."project_datas"
    ADD CONSTRAINT "project_datas_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."student_final_deliverables"
    ADD CONSTRAINT "student_final_deliverables_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."student_final_deliverables"
    ADD CONSTRAINT "student_final_deliverables_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."student_project_progress"
    ADD CONSTRAINT "student_project_progress_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."student_project_progress"
    ADD CONSTRAINT "student_project_progress_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."student_projects"
    ADD CONSTRAINT "student_projects_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."student_projects"
    ADD CONSTRAINT "student_projects_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "public"."students"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."student_weekly_uploads"
    ADD CONSTRAINT "student_weekly_uploads_project_id_fkey" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."student_weekly_uploads"
    ADD CONSTRAINT "student_weekly_uploads_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."students"
    ADD CONSTRAINT "students_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_trials"
    ADD CONSTRAINT "user_trials_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



CREATE POLICY "Allow delete for admin and superadmin" ON "public"."project_datas" FOR DELETE USING ((("auth"."role"() = 'authenticated'::"text") AND ("public"."get_admin_role"("auth"."uid"()) = ANY (ARRAY['superadmin'::"text", 'admin'::"text"]))));



CREATE POLICY "Allow delete for admin and superadmin" ON "public"."projects" FOR DELETE USING ((("auth"."role"() = 'authenticated'::"text") AND ("public"."get_admin_role"("auth"."uid"()) = ANY (ARRAY['superadmin'::"text", 'admin'::"text"]))));



CREATE POLICY "Allow insert for admin and superadmin" ON "public"."project_datas" FOR INSERT WITH CHECK ((("auth"."role"() = 'authenticated'::"text") AND ("public"."get_admin_role"("auth"."uid"()) = ANY (ARRAY['superadmin'::"text", 'admin'::"text"]))));



CREATE POLICY "Allow insert for admin and superadmin" ON "public"."projects" FOR INSERT WITH CHECK ((("auth"."role"() = 'authenticated'::"text") AND ("public"."get_admin_role"("auth"."uid"()) = ANY (ARRAY['superadmin'::"text", 'admin'::"text"]))));



CREATE POLICY "Allow read access for all users" ON "public"."project_datas" FOR SELECT USING (true);



CREATE POLICY "Allow read access for all users" ON "public"."projects" FOR SELECT USING (true);



CREATE POLICY "Allow read access for authenticated admins" ON "public"."admin_invitations" FOR SELECT USING ((("auth"."role"() = 'authenticated'::"text") AND ("public"."get_admin_role"("auth"."uid"()) = ANY (ARRAY['superadmin'::"text", 'admin'::"text", 'reviewer'::"text"]))));



CREATE POLICY "Allow read access for authenticated admins" ON "public"."admins" FOR SELECT USING ((("auth"."role"() = 'authenticated'::"text") AND ("public"."get_admin_role"("auth"."uid"()) = ANY (ARRAY['superadmin'::"text", 'admin'::"text", 'reviewer'::"text"]))));



CREATE POLICY "Allow update for admin, reviewer and superadmin" ON "public"."project_datas" FOR UPDATE USING ((("auth"."role"() = 'authenticated'::"text") AND ("public"."get_admin_role"("auth"."uid"()) = ANY (ARRAY['superadmin'::"text", 'admin'::"text", 'reviewer'::"text"]))));



CREATE POLICY "Allow update for admin, reviewer and superadmin" ON "public"."projects" FOR UPDATE USING ((("auth"."role"() = 'authenticated'::"text") AND ("public"."get_admin_role"("auth"."uid"()) = ANY (ARRAY['superadmin'::"text", 'admin'::"text", 'reviewer'::"text"]))));



CREATE POLICY "Delete own deliverable" ON "public"."student_final_deliverables" FOR DELETE USING (("auth"."uid"() = "student_id"));



CREATE POLICY "Delete own progress" ON "public"."student_project_progress" FOR DELETE USING (("auth"."uid"() = "student_id"));



CREATE POLICY "Delete own weekly upload" ON "public"."student_weekly_uploads" FOR DELETE USING (("auth"."uid"() = "student_id"));



CREATE POLICY "Insert own deliverable" ON "public"."student_final_deliverables" FOR INSERT WITH CHECK (("auth"."uid"() = "student_id"));



CREATE POLICY "Insert own progress" ON "public"."student_project_progress" FOR INSERT WITH CHECK (("auth"."uid"() = "student_id"));



CREATE POLICY "Insert own trial record" ON "public"."user_trials" FOR INSERT WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Insert own weekly upload" ON "public"."student_weekly_uploads" FOR INSERT WITH CHECK (("auth"."uid"() = "student_id"));



CREATE POLICY "Read own deliverables" ON "public"."student_final_deliverables" FOR SELECT USING (("auth"."uid"() = "student_id"));



CREATE POLICY "Read own progress" ON "public"."student_project_progress" FOR SELECT USING (("auth"."uid"() = "student_id"));



CREATE POLICY "Read own trial status" ON "public"."user_trials" FOR SELECT USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Read own weekly uploads" ON "public"."student_weekly_uploads" FOR SELECT USING (("auth"."uid"() = "student_id"));



CREATE POLICY "Students can delete their project links" ON "public"."student_projects" FOR DELETE USING (("auth"."uid"() = "student_id"));



CREATE POLICY "Students can insert their own profile" ON "public"."students" FOR INSERT WITH CHECK (("auth"."uid"() = "id"));



CREATE POLICY "Students can insert their project links" ON "public"."student_projects" FOR INSERT WITH CHECK (("auth"."uid"() = "student_id"));



CREATE POLICY "Students can read their own profile" ON "public"."students" FOR SELECT USING (("auth"."uid"() = "id"));



CREATE POLICY "Students can read their project links" ON "public"."student_projects" FOR SELECT USING (("auth"."uid"() = "student_id"));



CREATE POLICY "Students can update their own profile" ON "public"."students" FOR UPDATE USING (("auth"."uid"() = "id"));



CREATE POLICY "Students can update their project links" ON "public"."student_projects" FOR UPDATE USING (("auth"."uid"() = "student_id"));



CREATE POLICY "Superadmin delete only" ON "public"."admin_invitations" FOR DELETE USING ((("auth"."role"() = 'authenticated'::"text") AND ("public"."get_admin_role"("auth"."uid"()) = 'superadmin'::"text")));



CREATE POLICY "Superadmin delete only" ON "public"."admins" FOR DELETE USING ((("auth"."role"() = 'authenticated'::"text") AND ("public"."get_admin_role"("auth"."uid"()) = 'superadmin'::"text")));



CREATE POLICY "Superadmin insert only" ON "public"."admin_invitations" FOR INSERT WITH CHECK ((("auth"."role"() = 'authenticated'::"text") AND ("public"."get_admin_role"("auth"."uid"()) = 'superadmin'::"text")));



CREATE POLICY "Superadmin insert only" ON "public"."admins" FOR INSERT WITH CHECK ((("auth"."role"() = 'authenticated'::"text") AND ("public"."get_admin_role"("auth"."uid"()) = 'superadmin'::"text")));



CREATE POLICY "Superadmin update only" ON "public"."admin_invitations" FOR UPDATE USING ((("auth"."role"() = 'authenticated'::"text") AND ("public"."get_admin_role"("auth"."uid"()) = 'superadmin'::"text")));



CREATE POLICY "Superadmin update only" ON "public"."admins" FOR UPDATE USING ((("auth"."role"() = 'authenticated'::"text") AND ("public"."get_admin_role"("auth"."uid"()) = 'superadmin'::"text")));



CREATE POLICY "Update own deliverable" ON "public"."student_final_deliverables" FOR UPDATE USING (("auth"."uid"() = "student_id"));



CREATE POLICY "Update own progress" ON "public"."student_project_progress" FOR UPDATE USING (("auth"."uid"() = "student_id"));



CREATE POLICY "Update own trial record" ON "public"."user_trials" FOR UPDATE USING (("auth"."uid"() = "user_id"));



CREATE POLICY "Update own weekly upload" ON "public"."student_weekly_uploads" FOR UPDATE USING (("auth"."uid"() = "student_id"));



ALTER TABLE "public"."admin_invitations" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."admins" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."project_datas" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."projects" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."student_final_deliverables" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."student_project_progress" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."student_projects" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."student_weekly_uploads" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."students" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."testMig" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_trials" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";






GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

























































































































































GRANT ALL ON FUNCTION "public"."check_student_email_exists"("input_email" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."check_student_email_exists"("input_email" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."check_student_email_exists"("input_email" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."get_admin_role"("uid" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."get_admin_role"("uid" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_admin_role"("uid" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_updated_at_column"() TO "service_role";


















GRANT ALL ON TABLE "public"."admin_invitations" TO "anon";
GRANT ALL ON TABLE "public"."admin_invitations" TO "authenticated";
GRANT ALL ON TABLE "public"."admin_invitations" TO "service_role";



GRANT ALL ON TABLE "public"."admins" TO "anon";
GRANT ALL ON TABLE "public"."admins" TO "authenticated";
GRANT ALL ON TABLE "public"."admins" TO "service_role";



GRANT ALL ON TABLE "public"."project_datas" TO "anon";
GRANT ALL ON TABLE "public"."project_datas" TO "authenticated";
GRANT ALL ON TABLE "public"."project_datas" TO "service_role";



GRANT ALL ON TABLE "public"."projects" TO "anon";
GRANT ALL ON TABLE "public"."projects" TO "authenticated";
GRANT ALL ON TABLE "public"."projects" TO "service_role";



GRANT ALL ON TABLE "public"."student_final_deliverables" TO "anon";
GRANT ALL ON TABLE "public"."student_final_deliverables" TO "authenticated";
GRANT ALL ON TABLE "public"."student_final_deliverables" TO "service_role";



GRANT ALL ON TABLE "public"."student_project_progress" TO "anon";
GRANT ALL ON TABLE "public"."student_project_progress" TO "authenticated";
GRANT ALL ON TABLE "public"."student_project_progress" TO "service_role";



GRANT ALL ON TABLE "public"."student_projects" TO "anon";
GRANT ALL ON TABLE "public"."student_projects" TO "authenticated";
GRANT ALL ON TABLE "public"."student_projects" TO "service_role";



GRANT ALL ON TABLE "public"."student_weekly_uploads" TO "anon";
GRANT ALL ON TABLE "public"."student_weekly_uploads" TO "authenticated";
GRANT ALL ON TABLE "public"."student_weekly_uploads" TO "service_role";



GRANT ALL ON TABLE "public"."students" TO "anon";
GRANT ALL ON TABLE "public"."students" TO "authenticated";
GRANT ALL ON TABLE "public"."students" TO "service_role";



GRANT ALL ON TABLE "public"."testMig" TO "anon";
GRANT ALL ON TABLE "public"."testMig" TO "authenticated";
GRANT ALL ON TABLE "public"."testMig" TO "service_role";



GRANT ALL ON SEQUENCE "public"."testMig_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."testMig_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."testMig_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."user_trials" TO "anon";
GRANT ALL ON TABLE "public"."user_trials" TO "authenticated";
GRANT ALL ON TABLE "public"."user_trials" TO "service_role";



GRANT ALL ON SEQUENCE "public"."user_trials_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."user_trials_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."user_trials_id_seq" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






























RESET ALL;
