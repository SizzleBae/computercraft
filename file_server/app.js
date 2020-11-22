import express from 'express';
import fs from "fs"
import path from "path"

const publicDir = "../src/";

const app = express();
const port = 8000;

function getPathsRecursively(dirPath) {
    const files = fs.readdirSync(dirPath)

    const paths = []

    files.forEach(file => {
        const filePath = path.join(dirPath, file);
        console.log(filePath)

        if (fs.lstatSync(filePath).isDirectory()) {
            // This is a directiory
            const subPaths = getPathsRecursively(filePath);
            subPaths.forEach(subPath => {
                paths.push(path.join(file, subPath));
            })
        } else {
            // This is a file
            paths.push(file);
        }
    })

    return paths;
}

app.get('/api/file/*', (req, res) => {
    const targetPath = path.join(publicDir, req.params[0]);
    if (!fs.existsSync(targetPath)) {
        return res.status(404).send("File does not exist.");
    }

    if (fs.lstatSync(targetPath).isDirectory()) {
        return res.status(400).send("Path is a directory.");
    }

    return res.send(fs.readFileSync(targetPath));
})

app.get('/api/list/*', (req, res) => {
    const targetPath = path.join(publicDir, req.params[0]);
    if (!fs.existsSync(targetPath)) {
        return res.status(404).send("Directory does not exist.");
    }

    if (!fs.lstatSync(targetPath).isDirectory()) {
        return res.status(400).send("Path is not a directory.");
    }

    const paths = getPathsRecursively(targetPath);
    res.send(paths.join().replace(/\\/g, "/"));
})

app.listen(port, () => {
    console.log(`Example app listening at http://localhost:${port}`)
})