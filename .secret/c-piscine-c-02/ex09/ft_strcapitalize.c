/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_strcapitalize.c                                 :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: xcarroll <xcarroll@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2022/02/21 17:51:32 by xcarroll          #+#    #+#             */
/*   Updated: 2022/02/24 00:12:51 by xcarroll         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <stdio.h>

void	capitalise(char *str, int i)
{
	if (str[i] >= 'a' && str[i] <= 'z')
	{
		str[i] -= 32;
	}
}

void	un_capitalise(char *str)
{
	int	counter;

	counter = 0;
	while (str[counter] != '\0')
	{
		if (str[counter] >= 'A' && str[counter] <= 'Z')
		{
			str[counter] += 32;
		}
		counter++;
	}
	if (str[0] >= 'a' && str[0] <= 'z')
	{
		str[0] -= 32;
	}
}

char	*ft_strcapitalize(char *str)
{
	int	i;

	i = 1;
	un_capitalise(str);
	while (str[i] != '\0')
	{
		if (str[i - 1] >= ' ' && str[i - 1] <= '/')
			capitalise(str, i);
		else if (str[i - 1] >= ':' && str[i - 1] <= '@')
			capitalise(str, i);
		else if (str[i - 1] >= '[' && str[i - 1] <= '`')
			capitalise(str, i);
		else if (str[i - 1] >= '{' && str[i - 1] <= '~')
			capitalise(str, i);
		i++;
	}
	return (str);
}
/*
int	main(void)
{
	char str1[] = "salut, comment tu vas ? 42mots quarante-deux; cinquante+et+un";
	printf("%s\n", ft_strcapitalize(str1));
}
*/
