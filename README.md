
So you won't have to do 200 photos of some shoes, I've included the latter in the folder 'Example Model Images'. These images are provided by Apple. There you'll find 123 images of some shoe. You can use this as the input directory.

# How does this work?
You select the directory where you've got your fancy photos, then you select another directory which serves as your output (to where the 3D model and other stuff will be exported to). 

### Render Detail
Here you may select the Render Detail of the objects you get after processing. *Preview* will output the model with the lowest resolution, this is also the quickest process, while *Reduced*, *Medium*, *Full* and *Raw* will output high resolution models.

### Full Images Process
This will process the images from your input directory and will output 3D .obj file and a .png file which will contain the texture of the 3D model. You should use this .png file as your 'disolve', as the texture file for your 3D model.

### Process to .USDZ
This will output *only* the Model.usdz file which can be directly importat into your project and used within XCode. Note that this .usdz file will not contain any texture .png file. Hence it is recommended to do a full process and then export the .usdz file. Then you get to use both the 3D model as well as the texture .jpg files.


After processing has concluded you may preview your exported files (or .usdz) file via the *Preview Item* button. Press it and then choose the file you'd like to see. It will appear in the Prevew View below the *Render Detail* tabs.

##### Note that this process is heavy on the system. So use the best Mac you've got or it'll take you ages. Apple suggests to use the Macs with their silicon neuro fancy processor so it wont take as long. 

![alt text](https://github.com/Jonas1197/RealityKitConverterMacOS/blob/main/Images/screenshot.png?raw=true)

