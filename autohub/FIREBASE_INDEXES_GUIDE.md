# Firebase Index Creation Guide

## ⚠️ IMPORTANT: Collection Name Case Sensitivity

Your code uses lowercase `posts`, but you may have created an index for uppercase `Posts`. Firestore collection names are **case-sensitive**!

## Verify Your Collection Name

1. Go to Firebase Console → Firestore Database → **Data** tab
2. Check what your collection is actually named:
   - `posts` (lowercase) ✅
   - `Posts` (uppercase) ❌

## Create Index for Lowercase `posts`

### Step 1: Open Firebase Console
1. Go to https://console.firebase.google.com
2. Select your project: **autohub-819f4**
3. Click on **Firestore Database** in the left sidebar
4. Click on the **Indexes** tab at the top

### Step 2: Create the Required Index

Click **"Add index"** → **"Composite"** and configure:

**Collection ID:** `posts` (lowercase - must match your code!)

**Fields to index:**
1. Field: `postedBy` → Order: **Ascending** ✅
2. Field: `isActive` → Order: **Ascending** ✅  
3. Field: `timestamp` → Order: **Descending** ✅

**Query scope:** Collection

Click **Create**

### Step 3: Wait for Index to Build
- The index will show as "Building" initially
- It may take a few minutes to complete
- Refresh the page to check the status
- Once it shows "Enabled", the error will be resolved

## Why This Index is Needed

Your queries need to:
- Filter posts by `postedBy` (or multiple users with `whereIn`)
- Filter by `isActive == true`
- Sort by `timestamp` in descending order (newest first)

Firestore requires a composite index for queries that combine multiple filters with an orderBy clause.

## Quick Fix - Use Error Link
The **fastest way** is to click the link in the error message. It will automatically:
- Detect the correct collection name (`posts`)
- Pre-fill all the correct field configurations
- Create the index with one click

## Troubleshooting

If you still see errors after creating the index:
1. Make sure the index status shows "Enabled" (not "Building")
2. Verify the collection name is exactly `posts` (lowercase)
3. Refresh your Flutter app
4. Check that field names match exactly: `postedBy`, `isActive`, `timestamp`
5. Make sure `timestamp` is set to **Descending**, not Ascending

## Collection Name Mismatch

If you have both `Posts` and `posts` collections:
- Check which one your app actually uses
- You may need to standardize on one name
- Consider migrating data if you have both
