# Install the real TouRathi iPhone app using Windows and a free Apple ID

No TestFlight, App Store submission, Apple Developer Program membership,
Vercel deployment, local Mac, or jailbreak is needed for **personal testing**.

You need a Windows PC, your iPhone and USB cable, access to this GitHub
repository, and your personal Apple Account.

## 1. Build the unsigned iPhone app in GitHub

1. Open https://github.com/AdamChic04/tourathi/actions/workflows/ios-unsigned.yml
2. Select **Run workflow**, branch **main**, then **Run workflow**.
3. Wait for the `Build unsigned iPhone IPA` job to finish with a green check.
4. Open that workflow run; under **Artifacts**, download
   `TouRathi-iPhone-unsigned`.
5. Extract GitHub's artifact ZIP. Inside is
   `TouRathi-iPhone-unsigned.ipa`. **Do not unzip the IPA itself.**

The macOS runner compiles Flutter's real iOS app and bundles the results
in an unsigned IPA. It does NOT sign, install, publish or deploy the app.

## 2. Install from your Windows PC using Sideloadly

1. Get Sideloadly for Windows from https://sideloadly.io/
2. Follow Sideloadly's Windows instructions for Apple's desktop
   iTunes/iCloud components (their website specifies non-Microsoft-Store
   packages).
3. Connect the iPhone by USB, unlock it, and select **Trust** if prompted.
4. Open Sideloadly. Select your iPhone, drag in
   `TouRathi-iPhone-unsigned.ipa`, and enter your Apple ID when asked.
   Sideloadly uses the account to generate a free personal development
   signing profile. NEVER enter an Apple ID password in GitHub Actions.
5. Select **Start** to sign and install TouRathi.
6. On the iPhone, follow the trusted developer prompt if shown
   (Settings > General > VPN & Device Management).
   On iOS 16 or later, you may also have to enable **Developer Mode** under
   Settings > Privacy & Security, then restart the phone.
7. Open the TouRathi icon on the iPhone's Home Screen.

## What to expect

- TouRathi runs as a **native Flutter iOS app**, not a browser shortcut.
- The Supabase project still supplies login and tourism data over the internet.
  You are installing an app, not publishing a website or copying the database.
- Signing with a **free Apple ID expires after about 7 days**; Sideloadly
  can refresh the app when the computer is available. Free IDs typically
  permit up to **3 simultaneously sideloaded apps**.
- Some features still require separate backend setup: the AI Planner's
  hosted chat Worker is not included in this IPA, though on-device
  itinerary generation works as implemented.
- This package contains the latest code on `main`, including teammate
  contributions and the merged Food page. It is not a claim that all
  planned features (such as AR) are finished.
- If signing or installation fails, capture the Sideloadly error text; do
  not share your Apple ID password or two-factor authentication codes.

Sources:
- https://sideloadly.io/
- https://sideloadly.io/faq.html
- https://docs.github.com/en/actions/concepts/billing-and-usage
