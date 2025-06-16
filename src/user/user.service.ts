import {
  Injectable,
  NotFoundException,
  BadRequestException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../entities/user.entity';
import { CreateUserDto } from '../dto/create-user.dto';
import { UpdatePasswordDto } from '../dto/update-password.dto';

export interface UserResponse {
  id: string;
  login: string;
  version: number;
  createdAt: number;
  updatedAt: number;
}

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  private transformUser(user: User): UserResponse {
    return {
      id: user.id,
      login: user.login,
      version: user.version,
      createdAt:
        user.createdAt instanceof Date
          ? user.createdAt.getTime()
          : new Date(user.createdAt).getTime(),
      updatedAt:
        user.updatedAt instanceof Date
          ? user.updatedAt.getTime()
          : new Date(user.updatedAt).getTime(),
    };
  }

  private isValidUUID(id: string): boolean {
    const uuidRegex =
      /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    return uuidRegex.test(id);
  }

  async findAll(): Promise<UserResponse[]> {
    const users = await this.userRepository.find();
    return users.map((user) => this.transformUser(user));
  }

  async findOne(id: string): Promise<UserResponse> {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid user ID');
    }

    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    return this.transformUser(user);
  }

  async create(createUserDto: CreateUserDto): Promise<UserResponse> {
    const newUser = this.userRepository.create({
      login: createUserDto.login,
      password: createUserDto.password,
      version: 1,
    });

    const savedUser = await this.userRepository.save(newUser);
    return this.transformUser(savedUser);
  }

  async updatePassword(
    id: string,
    updatePasswordDto: UpdatePasswordDto,
  ): Promise<UserResponse> {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid user ID');
    }

    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (user.password !== updatePasswordDto.oldPassword) {
      throw new ForbiddenException('Wrong old password');
    }

    user.password = updatePasswordDto.newPassword;
    user.version += 1;

    const updatedUser = await this.userRepository.save(user);
    return this.transformUser(updatedUser);
  }

  async remove(id: string): Promise<void> {
    if (!this.isValidUUID(id)) {
      throw new BadRequestException('Invalid user ID');
    }

    const result = await this.userRepository.delete(id);
    if (result.affected === 0) {
      throw new NotFoundException('User not found');
    }
  }

  async findUserWithPassword(id: string): Promise<User | null> {
    return await this.userRepository.findOne({ where: { id } });
  }
}
