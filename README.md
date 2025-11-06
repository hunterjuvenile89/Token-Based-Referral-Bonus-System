# 🎯 Token-Based Referral Bonus System

A Clarity smart contract that rewards users for successful referrals with token-based bonuses! Perfect for building growth-focused dApps on the Stacks blockchain.

## 🌟 Features

- **👥 User Registration**: Users can register with or without a referrer
- **🔗 Referral Tracking**: Automatic tracking of referral relationships
- **⏰ Confirmation Logic**: Time-based confirmation system (144 blocks)
- **💰 Reward Distribution**: Automatic STX rewards for confirmed referrals
- **📊 Analytics**: Track referral counts and total rewards per user
- **🔐 Admin Controls**: Contract owner can confirm referrals and manage funds

## 🚀 Quick Start

### Prerequisites
- Clarinet CLI installed
- Stacks wallet for testing

### Installation
```bash
git clone <repository-url>
cd Token-Based-Referral-Bonus-System
clarinet console
```

## 📋 Contract Functions

### 🆕 User Registration
```clarity
(contract-call? .Token-Based-Referral-Bonus-System register (some 'SP1REFERRER))
```

### ✅ Confirm Referral (Admin Only)
```clarity
(contract-call? .Token-Based-Referral-Bonus-System confirm-referral u1)
```

### 💎 Claim Reward
```clarity
(contract-call? .Token-Based-Referral-Bonus-System claim-reward u1)
```

### 💰 Fund Contract
```clarity
(contract-call? .Token-Based-Referral-Bonus-System fund-contract)
```

## 🔍 Read-Only Functions

### 👤 Get User Info
```clarity
(contract-call? .Token-Based-Referral-Bonus-System get-user-info 'SP1USER)
```

### 📈 Get Referral Info
```clarity
(contract-call? .Token-Based-Referral-Bonus-System get-referral-info u1)
```

### 📊 Get User Referrals
```clarity
(contract-call? .Token-Based-Referral-Bonus-System get-user-referrals 'SP1USER)
```

### 💵 Get Contract Balance
```clarity
(contract-call? .Token-Based-Referral-Bonus-System get-contract-balance)
```

## ⚙️ Configuration

- **Referral Reward**: 1,000,000 microSTX (1 STX)
- **Confirmation Blocks**: 144 blocks (~24 hours)
- **Max Referrals per User**: 100

## 🛠️ Testing

```bash
clarinet test
```

## 🎯 Use Cases

- **🏢 Employee Referral Programs**: Reward employees for successful hires
- **👥 Client Referral Systems**: Incentivize customers to bring new clients
- **🌱 Growth Hacking**: Build viral loops with token rewards
- **🤝 Partnership Programs**: Reward partners for successful introductions

## 📝 Error Codes

- `u100`: Unauthorized access
- `u101`: User already registered
- `u102`: User not registered
- `u103`: Invalid referral
- `u104`: Already confirmed
- `u105`: Insufficient balance
- `u106`: Invalid amount
- `u107`: Referral not found

## 🔒 Security Features

- Only contract owner can confirm referrals
- Time-based confirmation prevents instant gaming
- Balance checks prevent over-spending
- Self-referral protection

## 🚦 Workflow

1. **📝 Register**: Users register with optional referrer
2. **⏳ Wait**: Confirmation period (144 blocks)
3. **✅ Confirm**: Admin confirms valid referrals
4. **💰 Claim**: Referrers claim their rewards
5. **🔄 Repeat**: Continuous referral cycle

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
