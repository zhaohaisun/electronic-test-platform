#include<stdio.h>
#include<stdlib.h>
#include"math.h"
#define M_PI 3.1415926535
//ÕýÏÒ²¨
int sine_wave(FILE * p,int maxwords,int depth)
{
	int i,j;
	for(i=0;i<depth;i++){
		j=(int)((maxwords/2-1)*sin(2*M_PI*i/depth)+maxwords/2);
		fprintf(p,"\t%-6d:%d;\n",i,j);
	}
	return 1;
 } 
 //ÓàÏÒ²¨
int cosine_wave(FILE * p,int maxwords,int depth)
{
	int i,j;
	for(i=0;i<depth;i++){
		j=(int)((maxwords/2-1)*cos(2*M_PI*i/depth)+maxwords/2);
		fprintf(p,"\t%-6d:%d;\n",i,j);
	}
	return 1;
 }  
 //·½²¨
 int square_wave(FILE *p,int maxwords,int depth)
{
	fprintf(p,"\t[ %d..%d] : %d;\n",0,depth/2,0);
	fprintf(p,"\t[ %d.. %d] : %d;\n",depth/2+1,depth-1,maxwords-1);
	return 1;	
} 
//Èý½Ç²¨
int triangle_wave(FILE *p,int maxwords,int depth)
{
	int i=0,j=0,k=0;
	k=2*(maxwords)/depth;
	for(i=0,j=0;i<depth;i++){
		fprintf(p,"\t % -6d: %d;\n",i,j);
		if(i<depth/2){
			j+=k;
		}
		else j-=k;
		if(j>=maxwords){
			j=maxwords-1;
		}
	}
	return 1;
}
//¾â³Ý²¨ 
int sawtooth_wave(FILE *p,int maxwords,int depth)
{
	int i=0,j=0,k=0;
	k=(maxwords-1)/(depth-1);
	for(i=0,j=0;i<depth;i++){
		fprintf(p,"\t %-6d: %d;\n",i,j);
		j+=k;
		if(j>=maxwords)j=maxwords-1;
	} 
	return 1;
}
int main()
{
	int i=0,j=0;
	int width=8;
	int depth=64;
	int maxwords=0;
	FILE *fp;
	if(!(fp=fopen("myfile.mif","w+"))){
		printf("open file error!\n");
		return -1; 
	}
	maxwords=1<<width;
	fprintf(fp,"WIDTH = % d;\nDEPTH = % d;\n\nADDRESS_RADIX = UNS;\nDATA_RADIX = UNS;\n\nCONTENT BEGIN\n",width,depth);
	cosine_wave(fp,maxwords,depth);
	//square_wave(fp,maxwords,depth);
	//triangle_wave(fp,maxwords,depth);
	//sawtooth_wave(fp,maxwords,depth);
	//sine_wave(fp,maxwords,depth);
	fprintf(fp,"END;\n");
	fclose(fp);
	printf(".mif generated successful!\n");
	system("PAUSE");
	return 0;
}
