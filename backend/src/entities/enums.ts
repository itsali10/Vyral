export enum Role {
  USER = 'USER',
  CREATOR = 'CREATOR',
  ADMIN = 'ADMIN',
}

export enum FollowStatus {
  PENDING = 'PENDING',
  ACCEPTED = 'ACCEPTED',
}

export enum PostType {
  IMAGE = 'IMAGE',
  CAROUSEL = 'CAROUSEL',
  VIDEO = 'VIDEO',
  TEXT = 'TEXT',
}

export enum NotificationType {
  LIKE = 'LIKE',
  COMMENT = 'COMMENT',
  FOLLOW = 'FOLLOW',
  FOLLOW_REQUEST = 'FOLLOW_REQUEST',
  MENTION = 'MENTION',
  MESSAGE = 'MESSAGE',
}

export enum ReportTarget {
  POST = 'POST',
  REEL = 'REEL',
  STORY = 'STORY',
  COMMENT = 'COMMENT',
  USER = 'USER',
}

export enum ReportStatus {
  PENDING = 'PENDING',
  REVIEWED = 'REVIEWED',
  DISMISSED = 'DISMISSED',
  ACTION_TAKEN = 'ACTION_TAKEN',
}
