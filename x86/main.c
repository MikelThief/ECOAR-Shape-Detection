#include <stdio.h>
#include <stdlib.h>

int FindShape(unsigned char* imageDataArray);

int main(int argc, char** argv)
{
    char* buff;
	FILE *imgFile;

    unsigned int len;

    if(argc !=  2) 
    {
        printf("Input argument was not specified correctly! \n ");
        return -1;
    }
    printf("Opening file...");
    imgFile = fopen(argv[1], "rb");
	if (imgFile == NULL)
	{
		printf("Error!\n");
		return -1;
	}
    else printf("Success\n");

    fseek(imgFile, 0, SEEK_END);
	len = ftell(imgFile);
	fseek(imgFile, 0, SEEK_SET);

    printf("Setting up buffer...");
    buff = (char *)malloc(sizeof(unsigned char) * len);
	if (buff == NULL) 
	{
		printf("Error!\n");
		fclose(imgFile);
		return -1;
	}
    else printf("Success\n");

    fread(buff, len, 1, imgFile);
	fclose(imgFile);

    int result = FindShape(buff + 54);

    if (result == 0) printf("No shape found.\n");
	else printf("Shape %i found.\n\n\n", result);


    return 0;
}