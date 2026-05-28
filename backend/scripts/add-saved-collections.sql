-- Run in Supabase SQL Editor if npm migration:run was not applied.
-- Adds what the backend expects for Saved screen + collections.

CREATE TABLE IF NOT EXISTS public.saved_collections (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  "userId" uuid NOT NULL,
  name character varying NOT NULL,
  "createdAt" timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT "PK_saved_collections" PRIMARY KEY (id),
  CONSTRAINT "FK_saved_collections_user"
    FOREIGN KEY ("userId") REFERENCES public.users (id) ON DELETE CASCADE
);

ALTER TABLE public.saved_posts
  ADD COLUMN IF NOT EXISTS "collectionId" uuid;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'FK_saved_posts_collection'
  ) THEN
    ALTER TABLE public.saved_posts
      ADD CONSTRAINT "FK_saved_posts_collection"
      FOREIGN KEY ("collectionId")
      REFERENCES public.saved_collections (id)
      ON DELETE SET NULL;
  END IF;
END $$;
