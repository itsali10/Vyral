import { Entity, PrimaryColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from './user.entity';
import { Conversation } from './conversation.entity';

@Entity('conversation_participants')
export class ConversationParticipant {
  @PrimaryColumn()
  conversationId: string;

  @PrimaryColumn()
  userId: string;

  @ManyToOne(() => Conversation, (conv) => conv.participants, {
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'conversationId' })
  conversation: Conversation;

  @ManyToOne(() => User, (user) => user.conversations, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;
}
