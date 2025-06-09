let model;
window.modelLoaded = false;

async function loadModel() {
    const URL = "./tm_model/";

    try {
        model = await tmImage.load(URL + "model.json", URL + "metadata.json");
        window.modelLoaded = true;
        //console.log("Model loaded successfully.");
    } catch (error) {
        window.modelLoaded = false;
        console.error("Error loading model:", error);
        alert("Failed to load the face recognition model.");
    }
}




async function predictFaceBase64(base64Image, callback) {
    if (!model) {
        callback("Model not loaded");
        //console.log("Model not loaded");
        return;
    }

    const img = new Image();
    img.src = base64Image;

    img.onload = async () => {
        try {
            const prediction = await model.predict(img);

            let bestLabel = "";
            let bestScore = 0;

            for (let p of prediction) {
                if (p.probability > bestScore) {
                    bestScore = p.probability;
                    bestLabel = p.className;
                }
            }


            callback(JSON.stringify({ label: bestLabel, score: bestScore }));
        } catch (err) {
            console.error("Prediction error:", err);
            callback("Prediction Failed");
        }
    };

    img.onerror = () => {
        console.error("Image could not load");
        callback("Image Load Failed");
    };
}


window.loadModel = loadModel;
window.predictFaceBase64 = predictFaceBase64;
