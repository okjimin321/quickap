### 📮 quickap

**"느린 것이 가장 빠른 것이다."** 과잉 연결 시대에 지친 당신을 위한, **기다림의 메신저 – quickap**

<br>

> [!NOTE]  
> 여기에 앱의 주요 기능을 보여주는 GIF나 대표 스크린샷을 넣으면 좋습니다. (예: `![quickap-demo](링크)`)

---

### 💡 개발 동기 (Motivation)

21세기 현대 사회는 과도한 연결성으로 인해 끊임없는 실시간 소통을 강요받고 있습니다. 우리는 항상 즉시 연결되어야 한다는 압박 속에서, 생각할 틈 없이 빠르게 메시지를 주고받는 데 익숙해졌습니다.

**quickap**은 이러한 문제의식에서 출발했습니다. 빠른 대화 속에서 놓치기 쉬운 '진심'을 되찾고자, 편지처럼 느리게 도착하는 메시지를 통해 **신중하고 의미 있는 소통이 가능한 공간**을 제공합니다. 사용자는 의도된 기다림을 통해 메시지 하나하나에 더 깊은 생각과 진심을 담을 수 있습니다.

> "느리고 신중하게 보낸 메시지가 더 큰 울림을 준다."

이 프로젝트는 기술을 통해 소통의 '속도'가 아닌 '깊이'를 추구함으로써, 디지털 환경에서의 긍정적인 사회적 상호작용과 건강한 소통 문화를 만드는 데 기여하고자 합니다.

---

### ✨ 주요 기능 (Features)

* **Firebase Authentication 기반 회원가입 및 로그인**
    * 이메일과 비밀번호로 간편하게 계정을 생성하고 안전하게 로그인할 수 있습니다.
    * `[여기에 로그인 화면 스크린샷 삽입]`

* **느린 배송 시스템**
    * 메시지 전송 시 배송 속도를 선택하여 의도적으로 지연된 소통을 경험할 수 있습니다.
        * 🚀 **특급 배송**: 30분 후 도착
        * 📦 **일반 배송**: 1시간 후 도착
        * 🐢 **보통 배송**: 3시간 후 도착
    * `[여기에 메시지 작성 및 전송 옵션 선택 화면 스크린샷 삽입]`

* **Firebase Cloud Firestore 기반 실시간 채팅**
    * 예정된 시간에 정확히 도착하는 메시지를 통해 친구와 편지처럼 대화할 수 있습니다.
    * `[여기에 채팅방 화면 스크린샷 삽입]`

---

### ⚙️ 기술 스택 (Tech Stack)

| 구분 | 기술 |
| :--- | :--- |
| **Frontend** | Flutter (Dart) |
| **Backend** | Firebase Authentication, Cloud Firestore |
| **State Management** | Provider (또는 사용하신 상태관리 기술) |
| **Deployment** | Android (향후 iOS 지원 예정) |

### 💻 오픈소스 활용 (Open-Source Software)

이 프로젝트는 다음과 같은 오픈소스 라이브러리 및 패키지를 활용하여 핵심 기능을 구현했습니다.

| 구분 (Category) | 패키지 (Package)                                                              | 설명 (Description)                                                                                             |
| :-------------- | :---------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------- |
| **Firebase 서비스** | `firebase_core`<br>`firebase_auth`<br>`cloud_firestore`                     | Firebase 핵심 연동, 이메일/비밀번호 기반 사용자 인증, 실시간 데이터베이스(채팅 메시지, 친구 목록 저장)를 위해 사용합니다. |
| **유틸리티 및 서식** | `intl`                                                                        | 날짜 및 시간 데이터의 포맷팅(예: '오후 3:30 도착 예정')을 위해 `DateFormat` 기능을 사용합니다.                      |
| **UI 프레임워크** | `flutter`                                                                     | Google에서 개발한 크로스플랫폼 UI 프레임워크로, Material Design 기반의 사용자 인터페이스를 구축하기 위해 사용합니다.      |

---

### 🚀 시작하기 (Getting Started)

#### **Prerequisites**
* Flutter SDK 3.x.x 이상
* Android Studio 또는 Visual Studio Code

#### **Installation & Run**
1.  **프로젝트 클론**
    ```bash
    git clone [https://github.com/okjimin321/quickap.git](https://github.com/okjimin321/quickap.git)
    cd quickap
    ```

2.  **Flutter 패키지 설치**
    ```bash
    flutter pub get
    ```

3.  **Firebase 설정**
    이 프로젝트는 Firebase를 사용하므로, 실행을 위해서는 본인의 Firebase 프로젝트 설정이 필요합니다.
    - [Firebase Console](https://console.firebase.google.com/)에서 새 프로젝트를 생성합니다.
    - Android 앱을 추가하고, 안내에 따라 `google-services.json` 파일을 다운로드하여 `android/app/` 폴더에配置합니다.
    - **Authentication** > **시작하기** > **로그인 제공업체**에서 **이메일/비밀번호**를 활성화합니다.
    - **Firestore Database** > **데이터베이스 만들기** > **테스트 모드**로 Firestore를 활성화합니다.
    - FlutterFire CLI를 사용하여 `lib/firebase_options.dart` 파일을 생성합니다. [참고 문서](https://firebase.flutter.dev/docs/cli)

4.  **앱 실행**
    ```bash
    flutter run
    ```

---

### 📂 프로젝트 구조 (Project Structure)
'''
lib/
┣ main.dart              # 앱 시작점, 로그인 상태에 따른 라우팅 로직
┣ firebase_options.dart    # Firebase 설정 정보
┣ add_friend_screen.dart   # 친구추가 UI 및 로직
┣ chat_list_screen.dart    # 채팅방 목록 UI
┗ chat_room_screen.dart    # 채팅방 메시지 UI 및 전송 로직
'''

### 📜 라이선스 (License)

이 프로젝트는 **MIT License**를 따릅니다. 자세한 내용은 `LICENSE` 파일을 참고하세요.

---

### 🛣️ 향후 계획 (Roadmap)

* [ ] iOS 플랫폼 지원
* [ ] 사진 메시지 전송 기능 추가
* [ ] 다양한 메시지 지연 시간 옵션 제공 (예: 12시간, 24시간)
* [ ] 메시지 도착 알림 기능 고도화

---

### 🧑‍💻 기여자 (Contributor)

* **옥지민**: 아이디어, 앱 개발 및 디자인
    * GitHub: [@okjimin321](https://github.com/okjimin321)

<br>

*이 프로젝트는 2025 인하대학교 오픈소스SW 페스티벌 출품작입니다.*
