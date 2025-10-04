# Artha - Personal Finance Manager

A comprehensive personal finance management application built with Flutter that helps you track wallets, transactions, and debts with automated email import.

## 📱 Features

- **Multi-Wallet Management**: Track bank accounts, e-wallets, cash, investments
- **Transaction Tracking**: Income, expenses, and transfers between wallets
- **Debt Management**: Track money you lent or owe
- **Automated Import**: Auto-import transactions from bank/e-wallet emails using AI
- **Real-time Sync**: Multi-device synchronization
- **Analytics**: Spending insights and financial reports

## 🏗️ Architecture

This project uses a modern, cloud-based architecture:

- **Frontend**: Flutter (cross-platform: Android, iOS, Web, Desktop)
- **Backend**: Supabase (PostgreSQL-based Backend-as-a-Service)
- **Automation**: GitHub Actions + Gmail API for email processing
- **AI**: OpenRouter with DeepSeek R1 for intelligent email parsing

For detailed architecture documentation, see **[ARCHITECTURE.md](ARCHITECTURE.md)**.

For database schema and entity relationships, see **[ERD.md](ERD.md)**.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Supabase account (free tier available)
- GitHub account (for automated email processing)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/artha.git
   cd artha
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a project at [supabase.com](https://supabase.com)
   - Copy your project URL and anon key
   - Update `lib/main.dart` with your credentials

4. **Run the app**
   ```bash
   flutter run
   ```

## 📚 Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Complete system architecture, technology stack, and deployment guide
- **[ERD.md](ERD.md)** - Database schema, entity relationships, and business rules
- **README.md** - This file (quick start guide)

## 🤖 Automated Email Import

Artha can automatically import transactions from bank and e-wallet email notifications using AI-powered parsing.

**Supported Banks/E-Wallets** (Indonesia):
- Banks: BCA, Mandiri, BRI, BNI, CIMB, Permata
- E-wallets: GoPay, OVO, DANA, ShopeePay, LinkAja

See [ARCHITECTURE.md](ARCHITECTURE.md#automated-email-processing) for setup instructions.

## 💰 Cost

- **Development**: $0/month (free tiers)
- **Production**: $25-35/month (Supabase Pro + App Store fees)
- See [Cost Analysis](ARCHITECTURE.md#cost-analysis) for details

## 🛠️ Technology Stack

| Component | Technology | Cost |
|-----------|-----------|------|
| Frontend | Flutter/Dart | Free |
| Backend | Supabase | $0-25/mo |
| Database | PostgreSQL (via Supabase) | Included |
| Auth | Supabase Auth | Included |
| Email Processing | GitHub Actions | Free |
| AI Parsing | OpenRouter (DeepSeek R1) | Free |

## 📈 Roadmap

- [x] Core wallet and transaction management
- [x] Debt tracking
- [x] Architecture design
- [ ] Supabase integration
- [ ] Email automation setup
- [ ] Template system
- [ ] Labels and categorization
- [ ] Analytics and insights
- [ ] Budget tracking
- [ ] Multi-currency support

See [Future Improvements](ARCHITECTURE.md#future-improvements) for complete roadmap.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

**Samodra**

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev)
- Powered by [Supabase](https://supabase.com)
- AI parsing by [OpenRouter](https://openrouter.ai) with DeepSeek R1

---

For detailed setup and deployment instructions, see [ARCHITECTURE.md](ARCHITECTURE.md).
