import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { Transform, Exclude, Expose } from 'class-transformer';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  @Expose()
  id: string;

  @Column({ unique: true })
  @Expose()
  login: string;

  @Column()
  @Exclude()
  password: string;

  @Column({ default: 1 })
  @Expose()
  version: number;

  @CreateDateColumn()
  @Expose()
  @Transform(({ value }) => value.getTime(), { toPlainOnly: true })
  createdAt: Date;

  @UpdateDateColumn()
  @Expose()
  @Transform(
    ({ value }) => {
      if (value instanceof Date) {
        return value.getTime();
      }
      if (typeof value === 'string') {
        return new Date(value).getTime();
      }
      return value;
    },
    { toPlainOnly: true },
  )
  updatedAt: Date;
}
