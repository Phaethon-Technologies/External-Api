require("dotenv").config()

const express = require("express")

const app = express()
const jwt = require('jsonwebtoken')

const bcrypt = require("bcrypt")

app.use(express.json())

const users = []

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

const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiVmlzaG51IiwiaWF0IjoxNjgyNjgzOTg5fQ.Lhi5n4t5qlBwhLcn75Sm7kDpV95nG-vfTkHYhzHJtls';

fetch('http://localhost:3000/posts', {
  headers: {
    'Authorization': `Bearer ${token}`
  }
})
.then(response => response.json())
.then(data => console.log(data))
.catch(error => console.error(error));
app.post('/login',(req,res)=>{
    //auth user
    const username = req.body.username
    const user = {name: username}
    const accessToken =  jwt.sign(user, process.env.ACESS_TOKEN_SECRET)

    res.json({ accessToken: accessToken })
    })

app.get('/users',(req,res) =>{
    res.json(users)
})

app.post('/users', async (req,res)=> {

    try {
        
        const hashedPassword = await bcrypt.hash(req.body.password, 10)


    const user = {name: req.body.name, password: hashedPassword}

    users.push(user)

    res.status(201).send()
    }
    catch{
        res.status(500).send()
    }
})

app.post('/users/login', async (req,res)=>{
    const user = users.find(user => user.name = req.body.name)
    if(user == null){
        return res.status(400).send('Cannot find user')

    }
    try{
        if(await bcrypt.compare(req.body.password, user.password)){
            res.send('success')
        }
        else{
            res.send('Try Again')
        }
    }catch{
        res.status(500).send() 
    }
})



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
