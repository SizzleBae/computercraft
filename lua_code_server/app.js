import express from 'express';
import fs from "fs"
import path from "path"

const localRequireExp = new RegExp(/require '~(.*?)'/g);
const publicDir = "../src/";

const app = express();
const port = 8000;

function getPathsRecursively(dirPath) {
    const files = fs.readdirSync(dirPath)

    const paths = []

    files.forEach(file => {
        const filePath = path.join(dirPath, file);

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

function validatePath(...paths) {
    if (!paths.every(path => typeof (path) == 'string')) {
        return undefined;
    }
    return path.join(...paths);
}

function getFile(...paths) {
    const targetPath = validatePath(...paths);
    if (!targetPath) {
        return undefined;
    }
    if (!fs.existsSync(targetPath)) {
        return undefined;
    }
    if (fs.lstatSync(targetPath).isDirectory()) {
        return undefined;
    }
    return fs.readFileSync(targetPath);
}

function directoryValid(...paths) {
    const targetPath = validatePath(...paths);
    if (!targetPath) {
        return false;
    }
    if (!fs.existsSync(targetPath)) {
        return false;
    }
    if (!fs.lstatSync(targetPath).isDirectory()) {
        return false;
    }
    return true;
}

app.get('/api/file/*', (req, res) => {
    const targetFile = getFile(publicDir, req.params[0]);
    if (!targetFile) {
        return res.status(400).send("Invalid file path.");
    }
    return res.status(200).send(targetFile);
})

// Returns an array representing the path required from a lua script
function getRequireAbsolutePath(localReqiureStr, luaPath) {
    const requirePath = localReqiureStr.match(/'(.*?)'/)[0].slice(2, -1);
    return path.join(luaPath, "../", requirePath).replace(/\\/g, '/');
}

app.get('/api/lua-local/*', (req, res) => {
    console.log(`GET lua-local: ${req.params[0]}`)

    const targetFile = getFile(publicDir, req.params[0]);
    if (!targetFile) {
        return res.status(400).send("Invalid target file path.");
    }

    const luaRaw = targetFile.toString('utf-8');

    // Replace all require paths with paths relative to the origin directory
    const luaLocal = luaRaw.replace(localRequireExp, (requireStr) => {
        const requireAbsolutePath = getRequireAbsolutePath(requireStr, req.params[0]).split('/');
        return `require '.${requireAbsolutePath.join('.')}'`;
    })

    return res.status(200).send(luaLocal);
})

function getDependenciesRecursively(luaPath, result) {
    if (!result.dependencies) {
        result.dependencies = new Set();
    }

    // Avoid dependency loops
    if (result.dependencies.has(luaPath)) {
        return;
    }
    result.dependencies.add(luaPath);

    const targetFile = getFile(publicDir, luaPath);
    if (!targetFile) {
        result.error = `Invalid path: ${luaPath}`;
        return;
    }

    const luaCode = targetFile.toString('utf-8');
    const requires = luaCode.match(localRequireExp);

    // Return if there are no relative dependencies
    if (!requires) {
        return;
    }

    for (const requireStr of requires) {
        const requireAbsolutePath = getRequireAbsolutePath(requireStr, luaPath) + '.lua';
        getDependenciesRecursively(requireAbsolutePath, result);
    }
}

app.get('/api/lua-dependencies/*', (req, res) => {
    console.log(`GET lua-dependencies: ${req.params[0]}`)

    const result = {};
    getDependenciesRecursively(req.params[0], result);

    if (result.error) {
        return res.status(400).send(result.error);
    }
    return res.status(200).send(Array.from(result.dependencies).join());
})

app.get('/api/list/*', (req, res) => {
    if (!directoryValid(publicDir, req.params[0])) {
        return res.status(404).send("Invalid directory path.");
    }
    const targetPath = path.join(publicDir, req.params[0]);

    const paths = getPathsRecursively(targetPath);
    return res.status(200).send(paths.join().replace(/\\/g, "/"));
})

app.listen(port, () => {
    console.log(`File server listening at http://localhost:${port}`)
})