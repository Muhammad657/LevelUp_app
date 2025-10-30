# 🎓 LevelUp — College Admissions Companion App

**LevelUp** is an all-in-one, free platform that helps simplify and strengthen the college admissions journey.  

The home page greets each user personally and displays:
- Their **personalized college list**
- A **year-by-year checklist** to help them stay on track for their dream college  

It also includes:
- An **Admissions Calculator** that estimates acceptance chances based on GPA, test scores, and extracurriculars  
- A **College Search Tool** with filters for acceptance rate, location, and academic atmosphere  
- A **Scholarship Database** where users can browse, find, and save their top opportunities  

Additionally:
- The **Extracurricular Recommendation Page** uses the OpenAI API to analyze a student’s interests and recommend activities that enhance their profile  
- **GradMate**, an AI-powered college counseling assistant, offers personalized guidance on applications, essays, test prep, and extracurricular strategy — all while staying aware of the user’s stats  

The **Profile Page** lets students store personal details like name, grade, and avatar, as well as academic stats such as test scores, GPA, activities, and interests.

---

## ⚠️ Note on Data Completeness

Currently, only **3–4 colleges and scholarships** are fully completed.  
This will be **expanded and updated in the future**, as new data and features are added.

---

## 🧠 Project Structure

This is a **Flutter project**.  
The main application logic is located in the **`lib/levelup/`** folder — that’s where the core code for LevelUp resides.  

Other files in `lib/` support general configuration, navigation, and shared widgets **that are not in use.**

---

## 🛠️ Getting Started (Developers)

To run this project locally:

```bash
flutter pub get
flutter run
