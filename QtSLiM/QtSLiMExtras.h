#ifndef QTSLIMEXTRAS_H
#define QTSLIMEXTRAS_H

#include <QObject>
#include <QWidget>
#include <QColor>
#include <QRect>
#include <QPainter>


void QtSLiMFrameRect(const QRect &p_rect, const QColor &p_color, QPainter &p_painter);

QColor QtSLiMColorWithWhite(double p_white, double p_alpha);
QColor QtSLiMColorWithRGB(double p_white, double p_alpha);

void RGBForFitness(double fitness, float *colorRed, float *colorGreen, float *colorBlue, double scalingFactor);
void RGBForSelectionCoeff(double selectionCoeff, float *colorRed, float *colorGreen, float *colorBlue, double scalingFactor);



#endif // QTSLIMEXTRAS_H





































