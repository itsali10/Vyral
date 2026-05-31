-- Run once in Supabase Dashboard → SQL Editor.
-- Creates a public bucket for post images, avatars, stories, and reels.

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'media',
  'media',
  true,
  15728640,
  ARRAY[
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/gif',
    'video/mp4',
    'video/webm'
  ]
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Public read (required for feed images in the Flutter/web client).
DROP POLICY IF EXISTS "Public read media" ON storage.objects;
CREATE POLICY "Public read media"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'media');
