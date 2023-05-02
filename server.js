require("dotenv").config()

const express = require("express")

const app = express()
const jwt = require('jsonwebtoken')

const cors = require('cors');
app.use(cors());

const corsOptions = {
    origin: ['http://localhost:3000/', 'http://192.168.1.40:8081/posts.html']
  };
  app.use(cors(corsOptions));


app.use(express.json())

const posts = [
    {
        username:"Vishnu",
        title:"Post 1"
    },

    {
    username:"Arun",
    title:"Post 2"
    }
]

app.get('/posts',  authToken , (req,res)=> {
res.json(posts.filter(post => post.username === req.user.name))
})


app.post('/login',(req,res)=>{
    //auth user
    const username = req.body.username
    const user = {name: username}
    const accessToken =  jwt.sign(user, process.env.ACESS_TOKEN_SECRET)

    res.json({ accessToken: accessToken })
    })

    const token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiVmlzaG51IiwiaWF0IjoxNjgyOTI0OTQ5fQ.uBiw8atoP-lMw1_kJifcwqsgVQBf_BnWbM2BfXZ_dWs" 

    const url = 'http://localhost:3000/posts';

    fetch(url, {
      headers: {
        'Authorization': 'Bearer ' + token
      }
    })
    .then(response => response.json())
    .then(data => {
      const postsContainer = document.querySelector('#posts-container');
    
      data.forEach(post => {
        const postElement = document.createElement('div');
        postElement.innerHTML = `
          <h2>${post.title}</h2>
          <p>By ${post.username}</p>
        `;
        postsContainer.appendChild(postElement);
      });
    })
    .catch(error => {
      console.error('Error fetching posts:', error);
    });


console.log('hi')

function authToken(req,res,next){
const authHeader = req.headers['authorization']
const token = authHeader && authHeader.split(' ')[1]    
if(token == null) return res.sendStatus(401)

jwt.verify(token, process.env.ACESS_TOKEN_SECRET, (err,user)=>{
    if(err) return res.sendStatus(403)
    req.user = user
    next()
})
}
app.listen(3000)


