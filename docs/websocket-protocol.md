# 웹소켓 프로토콜 (초안)

서버는 메시지 내용을 해석하지 않고 암호문만 저장하고 전달합니다. 본문, 비밀 구간, 서식 정보는 모두 `ciphertext` 안에 들어 있습니다.

## 연결

```
wss://{host}/rooms/{roomId}/ws
Authorization: Bearer {Firebase ID 토큰}
```

핸드셰이크 단계에서 토큰을 검증하고, 요청한 사용자가 해당 방의 `ACTIVE` 멤버인지 확인합니다. 조건을 만족하지 않으면 연결을 거부합니다.

## 클라이언트 → 서버

### `send` 메시지 전송

```json
{
  "type": "send",
  "epoch": 3,
  "nonce": "base64",
  "ciphertext": "base64"
}
```

| 필드 | 설명 |
|---|---|
| `epoch` | 암호화에 사용한 방 키 버전 |
| `nonce` | AES-GCM nonce (12바이트) |
| `ciphertext` | 암호화된 메시지 본문 |

## 서버 → 클라이언트

### `message` 새 메시지

```json
{
  "type": "message",
  "id": "uuid",
  "senderUid": "firebase-uid",
  "epoch": 3,
  "nonce": "base64",
  "ciphertext": "base64",
  "createdAt": 1760000000000,
  "expireAt": 1760086400000
}
```

`senderUid`는 클라이언트가 보낸 값이 아니라 서버가 토큰에서 확인한 값입니다. `expireAt`은 `createdAt`에서 24시간 뒤입니다.

### `member_updated` 멤버 변경

닉네임 변경, 참여 승인, 강퇴 시 전송합니다.

```json
{
  "type": "member_updated",
  "uid": "firebase-uid",
  "nickname": "새닉네임",
  "status": "ACTIVE"
}
```

### `key_rotated` 방 키 교체

멤버가 나가거나 강퇴되면 방 키 버전이 올라갑니다. 클라이언트는 새 버전의 방 키를 받아온 뒤 이후 메시지를 암호화합니다.

```json
{
  "type": "key_rotated",
  "epoch": 4
}
```

### `deleted` 메시지 삭제

```json
{
  "type": "deleted",
  "id": "uuid"
}
```

### `room_deleted` 방 삭제

클라이언트는 로컬 메시지와 방 키를 즉시 지우고 연결을 종료합니다.

```json
{
  "type": "room_deleted"
}
```
