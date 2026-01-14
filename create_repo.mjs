// import fetch from 'node-fetch'; // Using built-in fetch

const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const REPO_NAME = 'window-measurement-app';

async function createRepo() {
    console.log(`🔍 Checking/Creating repo: ${REPO_NAME}`);

    // Check if exists
    const check = await fetch(`https://api.github.com/repos/revyxon/${REPO_NAME}`, {
        headers: { Authorization: `Bearer ${GITHUB_TOKEN}` }
    });

    if (check.status === 200) {
        console.log('✅ Repo already exists.');
        return;
    }

    // Create
    const create = await fetch('https://api.github.com/user/repos', {
        method: 'POST',
        headers: {
            Authorization: `Bearer ${GITHUB_TOKEN}`,
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            name: REPO_NAME,
            private: true,
            description: 'Window Measurement App source code'
        })
    });

    if (!create.ok) {
        const err = await create.text();
        console.error(`❌ Failed to create repo: ${err}`);
        process.exit(1);
    }
    console.log('✅ Repo created successfully.');
}

createRepo();
