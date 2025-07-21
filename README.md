## Purpose
1. Recommends documents based on user input or requirements.
2. Admins can upload documents to **extend** the knowledge base in the **dashboard**.

## Tool stack

* Frontend: Vue3 / Pinia / shadcn-vue
* Backend: Ruby on rails / ruby-openai gem / pdf-reader gem / neighbor gem
* DB: supabase (with vector column)



## Demo

https://github.com/user-attachments/assets/b8d5dfd5-0d9d-4085-be51-463600e530dc

------

## JWT authentication sequence diagram (AT + RT)

RT is stored in the httponly + samesite cookie
AT is stored in browser memory (pinia store)

<img width="1651" height="2281" alt="Untitled" src="https://github.com/user-attachments/assets/5e2bc41a-0bcf-48ec-a693-398cc1ac5ae4" />
