import { formatTimeAgo } from '../utils/time-ago';
import { Post } from '../../entities/post.entity';
import { User } from '../../entities/user.entity';
import { PostType } from '../../entities/enums';

export type FeedPostView = {
  id: string;
  authorId: string;
  authorAvatarUrl: string | null;
  username: string;
  timeAgo: string;
  hasImage: boolean;
  caption: string | null;
  likesCount: number;
  commentsCount: number;
  mediaUrls: string[];
  isLiked: boolean;
  isSaved: boolean;
  showLikesCount: boolean;
  createdAt: Date;
};

export function toFeedPost(
  post: Post & { author?: User },
  options: {
    isLiked?: boolean;
    isSaved?: boolean;
    showLikesCount?: boolean;
  } = {},
): FeedPostView {
  const username = post.author?.username
    ? `@${post.author.username}`
    : '@unknown';
  const hasImage =
    post.mediaUrls.length > 0 && post.type !== PostType.TEXT;

  return {
    id: post.id,
    authorId: post.authorId,
    authorAvatarUrl: post.author?.avatarUrl ?? null,
    username,
    timeAgo: formatTimeAgo(post.createdAt),
    hasImage,
    caption: post.caption ?? null,
    likesCount: Math.max(0, post.likesCount),
    commentsCount: Math.max(0, post.commentsCount),
    mediaUrls: post.mediaUrls,
    isLiked: options.isLiked ?? false,
    isSaved: options.isSaved ?? false,
    showLikesCount: options.showLikesCount !== false,
    createdAt: post.createdAt,
  };
}

export function toPublicUser(user: User, stats: {
  postsCount: number;
  followersCount: number;
  followingCount: number;
}) {
  return {
    id: user.id,
    username: user.username,
    displayUsername: `@${user.username}`,
    fullName: user.fullName,
    bio: user.bio,
    avatarUrl: user.avatarUrl,
    websiteUrl: user.websiteUrl,
    pronouns: user.pronouns,
    isPrivate: user.isPrivate,
    isVerified: user.isVerified,
    postsCount: stats.postsCount,
    followersCount: stats.followersCount,
    followingCount: stats.followingCount,
    createdAt: user.createdAt,
  };
}
