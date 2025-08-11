# GitHub Pages Setup Instructions

## Quick Setup for samaili.github.io/syntra

Your landing page is now ready! Follow these steps to make it live:

### Step 1: Enable GitHub Pages
1. Go to your repository settings: https://github.com/SaMaili/syntra/settings/pages
2. Under "Source", select **"Deploy from a branch"**
3. Choose **"main"** branch 
4. Select **"/ docs"** folder
5. Click **"Save"**

### Step 2: Verify Deployment
- Your site will be available at: **https://samaili.github.io/syntra/**
- It may take 2-5 minutes to become live after enabling
- Check the Pages settings for build status

### Step 3: Test Your Site
Visit these URLs to verify everything works:
- 🏠 Landing page: https://samaili.github.io/syntra/
- 📄 Privacy policy: https://samaili.github.io/syntra/privacy-policy.html
- 🔍 Sitemap: https://samaili.github.io/syntra/sitemap.xml
- 🤖 Robots.txt: https://samaili.github.io/syntra/robots.txt

## What's Included

✅ **Professional Landing Page**
- Modern responsive design
- App feature showcase
- Call-to-action buttons for app download
- Mobile-optimized layout

✅ **SEO Optimized**
- Meta tags for search engines
- Open Graph tags for social media sharing
- JSON-LD structured data
- Sitemap for search engine indexing

✅ **Complete Privacy Policy**
- GDPR and CCPA compliant
- Play Store requirements met
- User-friendly formatting

✅ **Error Handling**
- Custom 404 page
- Proper navigation between pages

## Next Steps (Optional)

### Update App Store Links
Currently the download buttons point to the generic Play Store. Update these in `docs/index.html`:
```html
<!-- Change these URLs to your actual app store links -->
<a href="https://play.google.com/store/apps/details?id=your.app.id" class="btn btn-secondary" target="_blank">Download on Play Store</a>
```

### Custom Domain (Advanced)
If you want to use a custom domain like `syntra.app`:
1. Add a `CNAME` file to the docs folder with your domain
2. Configure DNS records with your domain provider
3. Enable HTTPS in GitHub Pages settings

## Troubleshooting

**Site not loading?**
- Wait 5-10 minutes after enabling GitHub Pages
- Check Pages settings for any error messages
- Ensure the branch and folder are correctly selected

**Want to update content?**
- Edit files in the `docs/` folder
- Changes automatically deploy when you push to main branch

---

🎉 **Your landing page is ready!** The site showcases your Syntra app professionally and is optimized for search engines and social media sharing.