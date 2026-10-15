# 데이터 모델 (PostgreSQL)

방 이름과 메시지 본문은 서버에 암호문으로만 저장합니다.

| 테이블 | 주요 컬럼 | 설명 |
|---|---|---|
| `users` | `uid`, `created_at` | Firebase uid만 저장 |
| `devices` | `id`, `uid`, `public_key`, `fcm_token`, `created_at` | 기기 공개 키(X25519)와 푸시 토큰 |
| `rooms` | `id`, `enc_name`, `owner_uid`, `key_epoch`, `created_at` | 방 이름은 방 키로 암호화 |
| `room_members` | `room_id`, `uid`, `nickname`, `color_index`, `role`, `status`, `joined_at` | `(room_id, nickname)` 유니크, `status`는 `PENDING` 또는 `ACTIVE` |
| `room_keys` | `room_id`, `device_id`, `epoch`, `eph_pub`, `nonce`, `ciphertext` | 기기마다 따로 암호화한 방 키 |
| `messages` | `id`, `room_id`, `sender_uid`, `epoch`, `nonce`, `ciphertext`, `created_at`, `expire_at` | `expire_at = created_at + 24시간` |
| `invites` | `code`, `room_id`, `created_by`, `expires_at`, `max_uses`, `use_count` | 초대 링크와 코드 |
| `reports` | `id`, `room_id`, `reporter_uid`, `reported_uid`, `content`, `created_at` | 신고자가 직접 복호화해 첨부한 내용 |

## 삭제 규칙

- `rooms`를 삭제하면 `room_members`, `room_keys`, `messages`, `invites`가 함께 삭제됩니다 (`ON DELETE CASCADE`).
- `expire_at`이 지난 메시지는 스케줄러가 주기적으로 삭제합니다.
- 1:1 방은 두 멤버 모두, 그룹 방은 방장만 방을 삭제할 수 있습니다.
