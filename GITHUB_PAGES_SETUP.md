# GitHub Pages Setup Guide for Syntra

This guide explains how to set up GitHub Pages for the Syntra repository to serve the landing page and privacy policy.

## Option 1: Serve from docs/ folder (Recommended)

1. **Go to repository Settings**
   - Navigate to https://github.com/SaMaili/syntra/settings/pages

2. **Configure GitHub Pages**
   - Under "Source", select "Deploy from a branch"
   - Choose "main" branch
   - Select "/ docs" folder
   - Click "Save"

3. **Access your site**
   - Site will be available at: https://samaili.github.io/syntra/
   - Landing page: https://samaili.github.io/syntra/
   - Privacy policy: https://samaili.github.io/syntra/privacy-policy.html

## Option 2: Serve from gh-pages branch

1. **Create gh-pages branch** (if not already done)
   ```bash
   git checkout -b gh-pages
   cp docs/* .
   git add .
   git commit -m "Setup GitHub Pages site"
   git push -u origin gh-pages
   ```

2. **Configure GitHub Pages**
   - Go to repository Settings → Pages
   - Under "Source", select "Deploy from a branch"
   - Choose "gh-pages" branch
   - Select "/ (root)" folder
   - Click "Save"

## Site Structure

The GitHub Pages site includes:

- **Landing Page** (`index.html`):
  - Hero section introducing Syntra
  - Features grid with 6 key app features
  - About section with app details
  - Call-to-action for Play Store download
  - Responsive design for all devices

- **Privacy Policy** (`privacy-policy.html`):
  - Complete privacy policy converted from markdown
  - Structured sections for easy reading
  - Play Store compliant
  - Mobile-responsive layout

- **Supporting Files**:
  - `styles.css` - Main responsive stylesheet
  - `privacy-styles.css` - Privacy page specific styles
  - `404.html` - Custom error page
  - `favicon.png` - App icon

## Features

✅ **Responsive Design**: Works perfectly on mobile and desktop  
✅ **Fast Loading**: Minimal external dependencies  
✅ **SEO Optimized**: Proper meta tags and structure  
✅ **Accessible**: Focus states and keyboard navigation  
✅ **Play Store Ready**: Compliant privacy policy included  

## Customization

To update the site:

1. Edit files in the `docs/` directory
2. Commit and push changes
3. GitHub Pages will automatically update

### Key files to customize:
- Update app store links in `index.html`
- Modify contact information in `privacy-policy.html` 
- Adjust colors/styling in `styles.css`

## Verification

Once GitHub Pages is enabled, verify:

1. Landing page loads correctly
2. Navigation between pages works
3. Privacy policy displays properly
4. Site is mobile-responsive
5. 404 page shows for invalid URLs

## Play Store Requirements

The privacy policy meets Play Store requirements by including:
- Data collection and usage details
- User rights and choices
- Contact information
- GDPR/CCPA compliance statements
- Children's privacy protection

---

**Note**: After setting up GitHub Pages, it may take a few minutes for the site to become available. Check the Pages settings for the exact URL.