SubLockX Smart Contract

SubLockX is a Clarity smart contract built on the Stacks blockchain that enables **subscription-based token locking and recurring payments**. It provides a trustless and transparent mechanism for service providers and users to manage recurring payments without intermediaries.  

---

Features
- **Subscription Locks** – Employers, businesses, or users can lock STX for recurring payments.  
- **Time-based Release** – Funds are gradually released based on subscription duration.  
- **Cancelable Subscriptions** – Employers can cancel or pause ongoing subscriptions.  
- **Transparent Tracking** – All subscription details can be read on-chain for accountability.  

---

Functions

Public Functions
- `create-subscription (recipient principal) (amount uint) (duration uint)`  
  Create a new subscription stream with locked STX.  

- `withdraw (id uint)`  
  Recipient withdraws available STX based on elapsed time.  

- `cancel-subscription (id uint)`  
  Employer cancels a subscription and retrieves unused funds.  

Read-only Functions
- `get-subscription (id uint)`  
  View details of a specific subscription by ID.  

---

Contract Structure
- `subscription-id` – Incremental ID tracker for subscriptions.  
- `subscriptions` – Mapping of subscription data (employer, recipient, amount, duration, withdrawn funds, and status).  
- Error constants for invalid actions (e.g., not recipient, not employer, zero amount, etc.).  

---

Use Cases
- **Streaming salaries** for remote workers.  
- **Subscription services** (newsletters, apps, platforms).  
- **Recurring donations** to DAOs, charities, or creators.  

---

Deployment
You can deploy SubLockX using [Clarinet](https://docs.hiro.so/clarinet):  

```bash
clarinet deploy
